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

    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        if ("getStudent".equals(action)) {
            Integer w = (Integer) session.getAttribute("cw");
            boolean high = (w != null && w >= 3);
            Student s = callService.selectStudent(high);
            resp.getWriter().write(s != null ? new ObjectMapper().writeValueAsString(s) : "{}");

        } else if ("record".equals(action)) {
            String sid = req.getParameter("studentId");
            boolean ok = "true".equals(req.getParameter("isCorrect"));
            if (sid == null || sid.trim().isEmpty()) { resp.getWriter().write("fail"); return; }
            if (callService.recordResult(sid, ok)) {
                session.setAttribute("cw", ok ? 0 : ((Integer) session.getAttribute("cw") != null ? (Integer) session.getAttribute("cw") + 1 : 1));
                resp.getWriter().write("success");
            } else {
                resp.getWriter().write("fail");
            }
        }
    }
}
