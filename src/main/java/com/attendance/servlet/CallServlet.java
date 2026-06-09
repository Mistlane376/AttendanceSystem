package com.attendance.servlet;

import com.attendance.model.Student;
import com.attendance.service.CallService;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/call")
public class CallServlet extends HttpServlet {
    private CallService callService = new CallService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        if ("getStudent".equals(action)) {
            Integer wrong = (Integer) session.getAttribute("consecutiveWrong");
            if (wrong == null) wrong = 0;
            boolean needHighScore = wrong >= 3;

            Student student = callService.selectStudent(needHighScore);
            resp.setContentType("application/json");
            if (student != null) {
                ObjectMapper mapper = new ObjectMapper();
                mapper.writeValue(resp.getWriter(), student);
            } else {
                resp.getWriter().write("{}");
            }
        } else if ("record".equals(action)) {
            String studentId = req.getParameter("studentId");
            boolean isCorrect = "true".equals(req.getParameter("isCorrect"));

            boolean success = callService.recordResult(studentId, isCorrect);
            if (success) {
                if (isCorrect) {
                    session.setAttribute("consecutiveWrong", 0);
                } else {
                    Integer wrong = (Integer) session.getAttribute("consecutiveWrong");
                    if (wrong == null) wrong = 0;
                    session.setAttribute("consecutiveWrong", wrong + 1);
                }
                resp.getWriter().write("success");
            } else {
                resp.getWriter().write("fail");
            }
        }
    }
}