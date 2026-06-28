package com.attendance.servlet;

import com.attendance.model.Student;
import com.attendance.service.StudentService;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

@WebServlet("/student")
@MultipartConfig
public class StudentServlet extends HttpServlet {
    private StudentService studentService = new StudentService();

    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession().getAttribute("user") == null) { resp.getWriter().write("{\"error\":\"请先登录\"}"); return; }
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");

        String action = req.getParameter("action");
        Map<String, Object> result = new HashMap<>();

        if ("edit".equals(action)) {
            Student s = new Student();
            s.setStudentId(req.getParameter("studentId"));
            s.setName(req.getParameter("name"));
            s.setGender(req.getParameter("gender"));
            s.setClassName(req.getParameter("className"));
            result.put("success", studentService.updateStudent(s));
        } else if ("delete".equals(action)) {
            result.put("success", studentService.deleteStudent(req.getParameter("studentId")));
        } else if ("clearAll".equals(action)) {
            int n = studentService.deleteAll();
            result.put("success", n > 0);
            result.put("count", n);
        } else if ("deleteByClass".equals(action)) {
            String cls = req.getParameter("className");
            if (cls == null || cls.trim().isEmpty()) { result.put("error", "请指定班级"); }
            else { int n = studentService.deleteByClass(cls); result.put("success", n > 0); result.put("count", n); }
        } else {
            result.put("error", "未知操作");
        }
        resp.getWriter().write(new ObjectMapper().writeValueAsString(result));
    }
}
