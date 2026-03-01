package gradebooksystem;

import java.awt.*;
import java.sql.*;
import javax.swing.*;

public class TeacherUI {

    JTextArea output;

    // -----------------------------
    // Database Connection
    // -----------------------------
    public static Connection getConnection() throws SQLException {
    String url =
        "jdbc:mysql://localhost:3306/GradebookSystem?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    String user = "root";
    String password = "Mikehall56!";

    try {
        // Forces the driver to load so you get a clear error if it's missing
        Class.forName("com.mysql.cj.jdbc.Driver");
    } catch (ClassNotFoundException e) {
        throw new SQLException("MySQL JDBC driver not found. Add mysql-connector-j .jar to Libraries.", e);
    }

    return DriverManager.getConnection(url, user, password);
}

    public TeacherUI() {
        JFrame frame = new JFrame("Gradebook System - Teacher View");
        frame.setSize(600, 500);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        output = new JTextArea();
        output.setEditable(false);

        JButton gradesBtn = new JButton("View All Grades");
        JButton missingBtn = new JButton("Missing Assignments");
        JButton riskBtn = new JButton("Students At Risk");

        gradesBtn.addActionListener(e -> viewAllGrades());
        missingBtn.addActionListener(e -> viewMissing());
        riskBtn.addActionListener(e -> viewAtRisk());

        JPanel buttons = new JPanel();
        buttons.add(gradesBtn);
        buttons.add(missingBtn);
        buttons.add(riskBtn);

        frame.add(buttons, BorderLayout.NORTH);
        frame.add(new JScrollPane(output), BorderLayout.CENTER);

        frame.setVisible(true);
    }

    
    void viewAllGrades() {
        output.setText("");

        String sql = """
            SELECT s.name, a.title, g.score
            FROM Grades g
            JOIN Students s ON g.student_id = s.student_id
            JOIN Assignments a ON g.assignment_id = a.assignment_id
            ORDER BY s.name
        """;

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                output.append(
                    rs.getString("name") + " - " +
                    rs.getString("title") + ": " +
                    rs.getInt("score") + "\n"
                );
            }

        } catch (SQLException e) {
            output.setText("Database error:\n" + e.getMessage());
        }
    }

    // -----------------------------
    // Missing Assignments
    // -----------------------------
    void viewMissing() {
        output.setText("");

        String sql = """
            SELECT s.name, a.title
            FROM Submissions sub
            JOIN Students s ON sub.student_id = s.student_id
            JOIN Assignments a ON sub.assignment_id = a.assignment_id
            WHERE sub.submitted = FALSE
            ORDER BY s.name
        """;

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                output.append(
                    rs.getString("name") +
                    " - Missing: " +
                    rs.getString("title") + "\n"
                );
            }

        } catch (SQLException e) {
            output.setText("Database error:\n" + e.getMessage());
        }
    }

    // -----------------------------
    // Students At Risk (< 60%)
    // -----------------------------
    void viewAtRisk() {
        output.setText("");

        String sql = """
            SELECT s.name,
                   ROUND((SUM(g.score) / SUM(a.points)) * 100, 2) AS avg
            FROM Grades g
            JOIN Assignments a ON g.assignment_id = a.assignment_id
            JOIN Students s ON g.student_id = s.student_id
            GROUP BY s.student_id
            HAVING avg < 60
        """;

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                output.append(
                    rs.getString("name") +
                    " - " +
                    rs.getDouble("avg") + "%\n"
                );
            }

        } catch (SQLException e) {
            output.setText("Database error:\n" + e.getMessage());
        }
        
    }
    

    // -----------------------------
    // Main
    // -----------------------------
    public static void main(String[] args) {
    SwingUtilities.invokeLater(TeacherUI::new);
}
}