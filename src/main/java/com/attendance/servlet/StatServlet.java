package com.attendance.servlet;

import com.attendance.dao.RecordDao;
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
import java.io.PrintWriter;
import java.util.*;

@WebServlet("/stat")
public class StatServlet extends HttpServlet {
    private StudentService studentService = new StudentService();
    private RecordDao recordDao = new RecordDao();

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();
        if (session.getAttribute("user") == null) { resp.sendRedirect("login.jsp"); return; }

        String fmt = req.getParameter("format");
        if ("csv".equals(fmt)) {
            resp.setContentType("text/csv;charset=UTF-8");
            resp.setHeader("Content-Disposition", "attachment; filename=stats.csv");
            resp.getOutputStream().write(0xEF); resp.getOutputStream().write(0xBB); resp.getOutputStream().write(0xBF);
            PrintWriter w = resp.getWriter();
            w.println("排名,学号,姓名,班级,点名次数,答对次数,正确率");
            List<Student> list = studentService.getAllStudents();
            list.sort((a,b) -> Double.compare(b.getCorrectRate(), a.getCorrectRate()));
            int rank = 1;
            for (Student s : list) {
                w.printf("%d,%s,%s,%s,%d,%d,%.1f%%\n", rank++,
                        s.getStudentId(), s.getName(), s.getClassName(),
                        s.getTotalCalled(), s.getTotalCorrect(), s.getCorrectRate());
            }
            w.flush();
        } else {
            List<Student> students = studentService.getAllStudents();
            req.setAttribute("students", students);
            req.setAttribute("totalCalls", students.stream().mapToInt(Student::getTotalCalled).sum());
            req.setAttribute("totalCorrect", students.stream().mapToInt(Student::getTotalCorrect).sum());
            req.setAttribute("totalRecords", recordDao.countAll());
            req.getRequestDispatcher("stat.jsp").forward(req, resp);
        }
    }
}
