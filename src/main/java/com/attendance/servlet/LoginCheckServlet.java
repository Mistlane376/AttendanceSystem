package com.attendance.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/loginCheck")   // 这个路径必须和表单action一致
public class LoginCheckServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 获取用户输入的用户名和密码
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // 简单验证（硬编码，仅用于测试）
        // 正式使用时可以改成从数据库查询
        if ("admin".equals(username) && "123".equals(password)) {
            // 登录成功，保存用户信息到 session
            HttpSession session = request.getSession();
            session.setAttribute("user", username);
            // 跳转到点名主页面
            response.sendRedirect("call.jsp");
        } else {
            // 登录失败，返回登录页并显示错误信息
            request.setAttribute("errorMsg", "用户名或密码错误");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 如果用户直接访问 /loginCheck，也跳转到登录页
        response.sendRedirect("login.jsp");
    }
}