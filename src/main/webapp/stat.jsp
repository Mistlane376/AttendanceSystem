<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, com.attendance.model.Student, com.attendance.model.Record" %>
<%
    if(session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    List<Student> students = (List<Student>) request.getAttribute("studentList");
    Integer totalCalls = (Integer) request.getAttribute("totalCalls");
    Integer totalRecords = (Integer) request.getAttribute("totalRecords");
    Integer totalCorrect = (Integer) request.getAttribute("totalCorrect");
    List<String[]> classDist = (List<String[]>) request.getAttribute("classDist");
    List<Record> recentRecords = (List<Record>) request.getAttribute("recentRecords");
    if (students == null) students = new java.util.ArrayList<>();
    if (totalCalls == null) totalCalls = 0;
    if (totalRecords == null) totalRecords = 0;
    if (totalCorrect == null) totalCorrect = 0;
    if (classDist == null) classDist = new java.util.ArrayList<>();
    if (recentRecords == null) recentRecords = new java.util.ArrayList<>();
    double overallRate = totalRecords > 0 ? (double) totalCorrect / totalRecords * 100 : 0;
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>统计报表 - 课堂点名系统</title>
    <script src="https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js"></script>
    <style>
        :root {
            --primary: #4f46e5;
            --primary-light: #6366f1;
            --success: #10b981;
            --danger: #ef4444;
            --warning: #f59e0b;
            --bg: #f1f5f9;
            --card: #ffffff;
            --text: #1e293b;
            --text-muted: #64748b;
            --border: #e2e8f0;
            --radius: 12px;
            --shadow: 0 1px 3px rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.04);
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: "Segoe UI", "微软雅黑", sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; }

        .navbar {
            background: var(--card); border-bottom: 1px solid var(--border);
            padding: 0 24px; height: 60px; display: flex; align-items: center;
            justify-content: space-between; box-shadow: var(--shadow);
            position: sticky; top: 0; z-index: 100;
        }
        .navbar .logo { font-size: 20px; font-weight: 700; color: var(--primary); }
        .navbar nav { display: flex; gap: 4px; }
        .navbar nav a {
            padding: 8px 16px; border-radius: 8px; text-decoration: none;
            color: var(--text-muted); font-weight: 500; font-size: 14px; transition: all 0.2s;
        }
        .navbar nav a:hover, .navbar nav a.active { background: #eef2ff; color: var(--primary); }
        .navbar .user-info { font-size: 14px; color: var(--text-muted); display: flex; align-items: center; gap: 12px; }
        .navbar .btn-logout { padding: 6px 14px; background: var(--danger); color: #fff; border: none; border-radius: 6px; cursor: pointer; font-size: 13px; }

        .container { max-width: 1200px; margin: 24px auto; padding: 0 24px; display: flex; flex-direction: column; gap: 24px; }
        .card { background: var(--card); border-radius: var(--radius); padding: 24px; box-shadow: var(--shadow); border: 1px solid var(--border); }
        .card h3 { font-size: 18px; margin-bottom: 16px; }

        /* 统计卡片 */
        .stat-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
        @media (max-width: 768px) { .stat-grid { grid-template-columns: repeat(2, 1fr); } }
        .stat-card {
            background: linear-gradient(135deg, #f8fafc, #fff); border: 1px solid var(--border);
            border-radius: var(--radius); padding: 20px; text-align: center;
        }
        .stat-card .val { font-size: 32px; font-weight: 700; }
        .stat-card .lbl { font-size: 13px; color: var(--text-muted); margin-top: 4px; }
        .stat-card.c1 .val { color: var(--primary); }
        .stat-card.c2 .val { color: #0891b2; }
        .stat-card.c3 .val { color: var(--success); }
        .stat-card.c4 .val { color: var(--warning); }

        /* 图表区域 */
        .charts-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 24px; }
        @media (max-width: 900px) { .charts-grid { grid-template-columns: 1fr; } }
        .chart-box { height: 380px; }

        /* 表格 */
        .table-wrapper { max-height: 450px; overflow-y: auto; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        th, td { padding: 10px 12px; border-bottom: 1px solid var(--border); text-align: center; }
        th { background: #f8fafc; font-weight: 600; color: var(--text-muted); font-size: 11px; text-transform: uppercase; letter-spacing: 0.5px; position: sticky; top: 0; }
        tr:hover { background: #f8fafc; }
        .rate-high { color: var(--success); font-weight: 600; }
        .rate-low { color: var(--danger); font-weight: 600; }
        .badge { display: inline-block; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 600; }
        .badge-correct { background: #d1fae5; color: #065f46; }
        .badge-wrong { background: #fee2e2; color: #991b1b; }

        .footer { text-align: center; padding: 24px; color: var(--text-muted); font-size: 13px; }
        .empty-hint { text-align: center; padding: 48px; color: var(--text-muted); font-size: 16px; }
    </style>
</head>
<body>
    <div class="navbar">
        <div class="logo">课堂点名系统</div>
        <nav>
            <a href="call.jsp">点名</a>
            <a href="stat" class="active">统计</a>
            <a href="import.jsp">导入学生</a>
        </nav>
        <div class="user-info">
            <span><%= session.getAttribute("user") %></span>
            <button class="btn-logout" onclick="location.href='login.jsp'">退出</button>
        </div>
    </div>

    <div class="container">
        <!-- 概览卡片 -->
        <div class="stat-grid">
            <div class="stat-card c1">
                <div class="val"><%= students.size() %></div>
                <div class="lbl">学生总数</div>
            </div>
            <div class="stat-card c2">
                <div class="val"><%= totalRecords %></div>
                <div class="lbl">点名总次数</div>
            </div>
            <div class="stat-card c3">
                <div class="val"><%= totalCorrect %></div>
                <div class="lbl">答对次数</div>
            </div>
            <div class="stat-card c4">
                <div class="val"><%= String.format("%.1f%%", overallRate) %></div>
                <div class="lbl">总正确率</div>
            </div>
        </div>

        <!-- 图表 -->
        <div class="charts-grid">
            <div class="card">
                <h3>学生点名次数与正确率</h3>
                <div id="chartBar" class="chart-box"></div>
            </div>
            <div class="card">
                <h3>班级人数分布</h3>
                <div id="chartPie" class="chart-box"></div>
            </div>
        </div>

        <!-- 学生详情表 -->
        <div class="card">
            <h3>学生点名统计明细</h3>
            <% if (students.isEmpty()) { %>
                <div class="empty-hint">暂无数据，请先导入学生</div>
            <% } else { %>
            <div class="table-wrapper">
                <table>
                    <thead>
                        <tr><th>排名</th><th>学号</th><th>姓名</th><th>班级</th><th>点名次数</th><th>答对次数</th><th>正确率</th></tr>
                    </thead>
                    <tbody>
                        <%
                            // 按正确率降序
                            List<Student> sorted = new java.util.ArrayList<>(students);
                            sorted.sort((a, b) -> Double.compare(b.getCorrectRate(), a.getCorrectRate()));
                            int rank = 1;
                            for(Student s : sorted) {
                                double r = s.getCorrectRate();
                                String cls = r >= 60 ? "rate-high" : (s.getTotalCalled() > 0 ? "rate-low" : "");
                        %>
                        <tr>
                            <td><%= rank++ %></td>
                            <td><%= s.getStudentId() %></td>
                            <td><%= s.getName() %></td>
                            <td><%= s.getClassName() %></td>
                            <td><%= s.getTotalCalled() %></td>
                            <td><%= s.getTotalCorrect() %></td>
                            <td class="<%= cls %>"><%= String.format("%.1f%%", r) %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>

        <!-- 最近记录 -->
        <div class="card">
            <h3>最近点名记录</h3>
            <% if (recentRecords.isEmpty()) { %>
                <div class="empty-hint" style="padding:24px;">暂无点名记录</div>
            <% } else { %>
            <div class="table-wrapper" style="max-height:300px;">
                <table>
                    <thead>
                        <tr><th>学号</th><th>点名时间</th><th>结果</th></tr>
                    </thead>
                    <tbody>
                        <% for(Record rec : recentRecords) { %>
                        <tr>
                            <td><%= rec.getStudentId() %></td>
                            <td><%= new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rec.getCallTime()) %></td>
                            <td><span class="badge <%= rec.isCorrect() ? "badge-correct" : "badge-wrong" %>"><%= rec.isCorrect() ? "答对" : "答错" %></span></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } %>
        </div>
    </div>

    <div class="footer">课堂点名系统 &copy; 2026</div>

    <script>
        // 柱状图 + 折线图：点名次数与正确率
        (function() {
            var names = [], called = [], rates = [];
            <% for(Student s : students) { %>
            names.push('<%= s.getName().replace("'", "\\'") %>');
            called.push(<%= s.getTotalCalled() %>);
            rates.push(<%= String.format("%.1f", s.getCorrectRate()) %>);
            <% } %>

            if (names.length === 0) return;

            var c1 = echarts.init(document.getElementById('chartBar'));
            c1.setOption({
                tooltip: { trigger: 'axis' },
                legend: { data: ['点名次数', '正确率(%)'], bottom: 0 },
                grid: { left: 50, right: 50, top: 20, bottom: 30 },
                xAxis: { type: 'category', data: names, axisLabel: { rotate: names.length > 8 ? 30 : 0, fontSize: 11 } },
                yAxis: [
                    { type: 'value', name: '次数', minInterval: 1 },
                    { type: 'value', name: '正确率(%)', max: 100 }
                ],
                series: [
                    { name: '点名次数', type: 'bar', data: called, itemStyle: { color: '#4f46e5' }, barMaxWidth: 30 },
                    { name: '正确率(%)', type: 'line', yAxisIndex: 1, data: rates, smooth: true, itemStyle: { color: '#10b981' }, lineStyle: { width: 2 } }
                ]
            });
        })();

        // 饼图：班级分布
        (function() {
            var pieData = [];
            <% for(String[] cd : classDist) { %>
            pieData.push({ name: '<%= cd[0].replace("'", "\\'") %>', value: <%= cd[1] %> });
            <% } %>

            if (pieData.length === 0) return;

            var c2 = echarts.init(document.getElementById('chartPie'));
            c2.setOption({
                tooltip: { trigger: 'item', formatter: '{b}: {c}人 ({d}%)' },
                legend: { orient: 'vertical', right: 10, top: 'center', textStyle: { fontSize: 12 } },
                series: [{
                    type: 'pie', radius: ['45%', '75%'], center: ['40%', '50%'],
                    itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
                    label: { show: false },
                    emphasis: { label: { show: true, fontSize: 16, fontWeight: 'bold' } },
                    data: pieData
                }]
            });
        })();
    </script>
</body>
</html>
