import fs from "node:fs/promises";
import path from "node:path";
import { NextResponse } from "next/server";
import { prisma } from "../../../../../../../lib/prisma";
import { normalizeJson, safeError } from "../../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

const documentNames = {
  orcamento_final: "orcamento.pdf",
  termo_quitacao: "termo_quitacao.pdf",
};

function documentBaseDirs() {
  return [
    process.env.CONFERENCE_DOWNLOADS_DIR,
    path.resolve(process.cwd(), "data", "conference_downloads"),
    path.resolve(process.cwd(), "..", "data", "conference_downloads"),
    path.resolve(process.cwd(), "..", "..", "data", "conference_downloads"),
  ].filter(Boolean);
}

async function readDocumentFile(fileName) {
  const tried = new Set();

  for (const baseDir of documentBaseDirs()) {
    const safeBase = path.resolve(baseDir);
    const resolvedPath = path.resolve(safeBase, fileName);
    if (path.dirname(resolvedPath) !== safeBase || tried.has(resolvedPath)) {
      continue;
    }
    tried.add(resolvedPath);

    try {
      return await fs.readFile(resolvedPath);
    } catch (error) {
      if (error?.code !== "ENOENT") {
        throw error;
      }
    }
  }

  return null;
}

export async function GET(request, { params }) {
  const auth = requirePermission(request, "DOWNLOAD_DOCUMENTOS");
  if (!auth.ok) return auth.response;

  try {
    const { os, tipo } = await params;
    if (!documentNames[tipo]) {
      return NextResponse.json({ ok: false, error: "Documento nao suportado." }, { status: 400 });
    }

    const rows = await prisma.$queryRaw`
      SELECT dadosExtraidos
      FROM consolidacoes
      WHERE os = ${os}
      LIMIT 1
    `;
    const row = rows[0];
    if (!row) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada." }, { status: 404 });
    }

    const dadosExtraidos = normalizeJson(row.dadosExtraidos);
    const filePath = dadosExtraidos?.downloads?.[tipo];
    if (!filePath) {
      return NextResponse.json({ ok: false, error: "Documento ainda nao foi baixado." }, { status: 404 });
    }

    const fileName = path.basename(filePath);
    if (!fileName || fileName !== filePath.split(/[\\/]/).pop()) {
      return NextResponse.json({ ok: false, error: "Caminho de documento invalido." }, { status: 400 });
    }

    const file = await readDocumentFile(fileName);
    if (!file) {
      return NextResponse.json({ ok: false, error: "Arquivo do documento nao encontrado no servidor." }, { status: 404 });
    }

    return new NextResponse(file, {
      headers: {
        "Content-Type": "application/pdf",
        "Content-Disposition": `inline; filename="${os}_${documentNames[tipo]}"`,
        "Cache-Control": "no-store",
      },
    });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
}
