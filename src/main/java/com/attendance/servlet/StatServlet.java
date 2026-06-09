package com.attendance.servlet;

import com.attendance.model.Student;
import com.attendance.service.StudentService;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/stat")

public class StatServlet extends HttpServlet {
    private StudentService studentService = new StudentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String accept = req.getHeader("Accept");
        List<Student> students = studentService.getAllStudents();

        if (accept != null && accept.contains("application/json")) {
            resp.setContentType("application/json");
            ObjectMapper mapper = new ObjectMapper();
            mapper.writeValue(resp.getWriter(), students);
        } else {
            req.setAttribute("studentList", students);
            req.getRequestDispatcher("stat.jsp").forward(req, resp);
        }
    }
}