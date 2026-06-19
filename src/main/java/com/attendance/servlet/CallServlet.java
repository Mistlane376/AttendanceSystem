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
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        String action = request.getParameter("action");
        HttpSession session = request.getSession();

        if ("getStudent".equals(action)) {
            Integer wrong = (Integer) session.getAttribute("consecutiveWrong");
            if (wrong == null) wrong = 0;
            boolean needHighScore = (wrong >= 3);

            Student student = callService.selectStudent(needHighScore);

            if (student != null) {
                ObjectMapper mapper = new ObjectMapper();
                String json = mapper.writeValueAsString(student);
                response.getWriter().write(json);
            } else {
                response.getWriter().write("{}");
            }

        } else if ("record".equals(action)) {
            String studentId = request.getParameter("studentId");
            boolean isCorrect = "true".equals(request.getParameter("isCorrect"));

            if (studentId == null || studentId.trim().isEmpty()) {
                response.getWriter().write("fail");
                return;
            }

            boolean success = callService.recordResult(studentId, isCorrect);

            if (success) {
                if (isCorrect) {
                    session.setAttribute("consecutiveWrong", 0);
                } else {
                    Integer wrong = (Integer) session.getAttribute("consecutiveWrong");
                    if (wrong == null) wrong = 0;
                    session.setAttribute("consecutiveWrong", wrong + 1);
                }
                response.getWriter().write("success");
            } else {
                response.getWriter().write("fail");
            }
        } else {
            response.getWriter().write("unknown action");
        }
    }
}