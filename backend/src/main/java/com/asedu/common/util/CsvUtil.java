package com.asedu.common.util;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.util.List;

/** CSV 导出工具（UTF-8 BOM，Excel 兼容） */
public final class CsvUtil {

    private CsvUtil() {
    }

    public static void write(OutputStream os, String[] header, List<String[]> rows) throws IOException {
        os.write(0xEF);
        os.write(0xBB);
        os.write(0xBF);
        Writer w = new OutputStreamWriter(os, StandardCharsets.UTF_8);
        if (header != null) {
            w.write(escape(header));
            w.write("\r\n");
        }
        if (rows != null) {
            for (String[] row : rows) {
                w.write(escape(row));
                w.write("\r\n");
            }
        }
        w.flush();
    }

    private static String escape(String[] cells) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < cells.length; i++) {
            if (i > 0) {
                sb.append(',');
            }
            String v = cells[i] == null ? "" : cells[i];
            if (v.contains(",") || v.contains("\"") || v.contains("\n") || v.contains("\r")) {
                sb.append('\"').append(v.replace("\"", "\"\"")).append('\"');
            } else {
                sb.append(v);
            }
        }
        return sb.toString();
    }
}
