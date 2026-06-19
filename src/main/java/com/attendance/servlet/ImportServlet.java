package com.attendance.servlet;

import com.attendance.model.Student;
import com.attendance.service.StudentService;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

@WebServlet("/import")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)  // 最大 10MB
public class ImportServlet extends HttpServlet {

    private StudentService studentService = new StudentService();
    private ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"error\":\"请先登录\"}");
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String type = request.getParameter("type");

        if ("batch".equals(type)) {
            // 批量手动输入（JSON）
            handleBatchEntry(request, response);
        } else {
            // 文件上传
            handleFileUpload(request, response);
        }
    }

    private void handleFileUpload(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        Map<String, Object> result = new HashMap<>();

        Part filePart = request.getPart("file");
        if (filePart == null || filePart.getSize() == 0) {
            result.put("error", "未选择文件");
            response.getWriter().write(mapper.writeValueAsString(result));
            return;
        }

        String fileName = getSubmittedFileName(filePart);
        if (fileName == null) {
            result.put("error", "无法获取文件名");
            response.getWriter().write(mapper.writeValueAsString(result));
            return;
        }

        String lowerName = fileName.toLowerCase();
        List<Student> students;

        try (InputStream is = filePart.getInputStream()) {
            if (lowerName.endsWith(".xlsx") || lowerName.endsWith(".xls")) {
                students = studentService.parseExcel(is, lowerName);
            } else if (lowerName.endsWith(".csv") || lowerName.endsWith(".txt")) {
                students = studentService.parseText(is);
            } else {
                result.put("error", "不支持的文件格式，请上传 .xlsx / .xls / .csv / .txt 文件");
                response.getWriter().write(mapper.writeValueAsString(result));
                return;
            }
        } catch (Exception e) {
            result.put("error", "文件解析失败: " + e.getMessage());
            response.getWriter().write(mapper.writeValueAsString(result));
            return;
        }

        if (students.isEmpty()) {
            result.put("error", "文件中未解析到有效数据，请检查格式（学号,姓名,班级）");
            response.getWriter().write(mapper.writeValueAsString(result));
            return;
        }

        Map<String, Object> importResult = studentService.batchImport(students);
        importResult.put("fileName", fileName);
        importResult.put("total", students.size());
        response.getWriter().write(mapper.writeValueAsString(importResult));
    }

    private void handleBatchEntry(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        Map<String, Object> result = new HashMap<>();

        String jsonBody = request.getParameter("data");
        if (jsonBody == null || jsonBody.trim().isEmpty()) {
            result.put("error", "未收到数据");
            response.getWriter().write(mapper.writeValueAsString(result));
            return;
        }

        List<Map<String, String>> rawList;
        try {
            rawList = mapper.readValue(jsonBody,
                    new com.fasterxml.jackson.core.type.TypeReference<List<Map<String, String>>>() {});
        } catch (Exception e) {
            result.put("error", "JSON 解析失败: " + e.getMessage());
            response.getWriter().write(mapper.writeValueAsString(result));
            return;
        }

        List<Student> students = new ArrayList<>();
        for (Map<String, String> item : rawList) {
            String sid = item.getOrDefault("studentId", "").trim();
            String name = item.getOrDefault("name", "").trim();
            String cls = item.getOrDefault("className", "").trim();
            if (!sid.isEmpty() && !name.isEmpty()) {
                students.add(new Student(sid, name, cls));
            }
        }

        if (students.isEmpty()) {
            result.put("error", "未解析到有效数据");
            response.getWriter().write(mapper.writeValueAsString(result));
            return;
        }

        Map<String, Object> importResult = studentService.batchImport(students);
        importResult.put("total", students.size());
        response.getWriter().write(mapper.writeValueAsString(importResult));
    }

    // 获取上传文件的原始文件名（兼容不同 Servlet 容器）
    private String getSubmittedFileName(Part part) {
        String disposition = part.getHeader("content-disposition");
        if (disposition == null) return null;
        for (String item : disposition.split(";")) {
            item = item.trim();
            if (item.startsWith("filename")) {
                String name = item.substring(item.indexOf('=') + 1).trim();
                return name.replaceAll("^\"|\"$", "");
            }
        }
        return null;
    }
}