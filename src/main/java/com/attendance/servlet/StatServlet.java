package com.attendance.servlet;

import com.attendance.dao.RecordDao;
import com.attendance.model.Record;
import com.attendance.model.Student;
import com.attendance.service.StudentService;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.*;

@WebServlet("/stat")
public class StatServlet extends HttpServlet {
    private StudentService studentService = new StudentService();
    private RecordDao recordDao = new RecordDao();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        if (session.getAttribute("user") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String format = request.getParameter("format");

        if ("json".equals(format)) {
            // API 返回 JSON 统计数据
            response.setContentType("application/json;charset=UTF-8");
            Map<String, Object> stats = new LinkedHashMap<>();
            stats.put("totalStudents", studentService.countAll());
            stats.put("totalCalls", studentService.totalCalled());
            stats.put("totalRecords", recordDao.countAll());
            stats.put("totalCorrect", recordDao.countCorrect());
            stats.put("classDistribution", studentService.classDistribution());
            stats.put("recentRecords", recordDao.getRecentRecords(20));
            new ObjectMapper().writeValue(response.getWriter(), stats);
        } else {
            // 默认跳转到统计页面
            List<Student> students = studentService.getAllStudents();
            request.setAttribute("studentList", students);
            request.setAttribute("totalCalls", studentService.totalCalled());
            request.setAttribute("totalRecords", recordDao.countAll());
            request.setAttribute("totalCorrect", recordDao.countCorrect());
            request.setAttribute("classDist", studentService.classDistribution());
            request.setAttribute("recentRecords", recordDao.getRecentRecords(20));
            request.getRequestDispatcher("stat.jsp").forward(request, response);
        }
    }
}