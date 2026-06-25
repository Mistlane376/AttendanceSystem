package com.attendance.servlet;

import com.attendance.model.Student;
import com.attendance.service.StudentService;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet("/import")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
public class ImportServlet extends HttpServlet {
    private StudentService studentService = new StudentService();
    private ObjectMapper mapper = new ObjectMapper();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession().getAttribute("user") == null) { resp.getWriter().write("{\"error\":\"请先登录\"}"); return; }
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String type = req.getParameter("type");
        if ("batch".equals(type)) {
            String json = req.getParameter("data");
            List<Map<String, String>> raw = mapper.readValue(json, new com.fasterxml.jackson.core.type.TypeReference<List<Map<String, String>>>() {});
            List<Student> list = new ArrayList<>();
            for (Map<String, String> m : raw) {
                String sid = m.getOrDefault("studentId", "").trim();
                String name = m.getOrDefault("name", "").trim();
                if (!sid.isEmpty() && !name.isEmpty()) list.add(new Student(sid, name, m.getOrDefault("className", "").trim()));
            }
            Map<String, Object> r = studentService.batchImport(list); r.put("total", list.size());
            resp.getWriter().write(mapper.writeValueAsString(r));
        } else {
            Part filePart = req.getPart("file");
            if (filePart == null || filePart.getSize() == 0) { resp.getWriter().write("{\"error\":\"未选择文件\"}"); return; }
            String fn = getFileName(filePart);
            List<Student> list;
            try (InputStream is = filePart.getInputStream()) {
                String lf = fn.toLowerCase();
                list = (lf.endsWith(".xlsx") || lf.endsWith(".xls")) ? studentService.parseExcel(is, lf) : studentService.parseText(is);
            } catch (Exception e) { resp.getWriter().write("{\"error\":\"解析失败: " + e.getMessage() + "\"}"); return; }
            if (list.isEmpty()) { resp.getWriter().write("{\"error\":\"未解析到数据\"}"); return; }
            Map<String, Object> r = studentService.batchImport(list); r.put("total", list.size());
            resp.getWriter().write(mapper.writeValueAsString(r));
        }
    }

    private String getFileName(Part part) {
        String d = part.getHeader("content-disposition");
        if (d == null) return null;
        for (String item : d.split(";")) if (item.trim().startsWith("filename"))
            return item.substring(item.indexOf('=') + 1).trim().replaceAll("^\"|\"$", "");
        return null;
    }
}
