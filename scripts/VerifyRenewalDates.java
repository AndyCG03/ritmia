import app.ritmia.ritmia.RenewalDates;
import java.time.LocalDate;
public class VerifyRenewalDates {
    static int count = 0;
    static void check(String expected, String anchor, String bought, String end, String cycle, String today) {
        LocalDate actual = RenewalDates.nextDate(anchor, bought, end, cycle, LocalDate.parse(today));
        if (!expected.equals(String.valueOf(actual))) throw new AssertionError(expected + " != " + actual);
        count++;
    }
    public static void main(String[] args) {
        check("2024-02-29", "2024-01-31", null, null, "monthly", "2024-02-01");
        check("2024-03-31", "2024-01-31", null, null, "monthly", "2024-03-01");
        check("2025-02-28", "2024-02-29", null, null, "yearly", "2025-02-01");
        check("2028-02-29", "2024-02-29", null, null, "yearly", "2028-02-01");
        check("2026-04-30", "2026-01-31", null, null, "quarterly", "2026-02-01");
        check("2026-11-16", "2026-10-16", "2026-10-16", null, "monthly", "2026-10-16");
        check("2026-10-23", "2026-10-16", "2026-10-16", null, "weekly", "2026-10-16");
        check("2026-10-30", "2026-09-30", null, "2026-10-30", "monthly", "2026-10-16");
        check("2026-10-01", "2026-09-01", null, "2026-10-01", "monthly", "2026-10-16");
        check("null", "2030-01-01", null, null, "monthly", "2026-10-16");
        System.out.println("Android recurrence checks passed: " + count);
    }
}
