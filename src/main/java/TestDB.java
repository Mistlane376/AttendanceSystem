import java.sql.Connection;
import com.attendance.util.JDBCUtil;

public class TestDB {
    public static void main(String[] args) {
        try (Connection conn = JDBCUtil.getConnection()) {
            System.out.println("数据库连接成功！");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}