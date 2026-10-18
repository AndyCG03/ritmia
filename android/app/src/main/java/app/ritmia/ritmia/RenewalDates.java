package app.ritmia.ritmia;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/** Civil-date arithmetic shared by all Android widget refreshes, independent of Android APIs. */
public final class RenewalDates {
    private RenewalDates() {}
    public static LocalDate nextDate(String anchorDate, String purchasedOn, String endsOn, String cycle, LocalDate today) {
        if (endsOn != null) return LocalDate.parse(endsOn);
        LocalDate anchor = LocalDate.parse(anchorDate);
        LocalDate bought = purchasedOn == null ? null : LocalDate.parse(purchasedOn);
        int step;
        switch (cycle) {
            case "monthly": step = 1; break;
            case "quarterly": step = 3; break;
            case "yearly": step = 12; break;
            case "weekly": step = 0; break;
            default: throw new IllegalArgumentException("Unknown billing cycle");
        }
        int months = (today.getYear() - anchor.getYear()) * 12 + today.getMonthValue() - anchor.getMonthValue();
        int index = Math.max(0, step == 0 ? (int) (ChronoUnit.DAYS.between(anchor, today) / 7) - 2 : months / step - 1);
        LocalDate until = today.plusYears(2);
        while (true) {
            LocalDate date = step == 0 ? anchor.plusWeeks(index) : anchor.plusMonths((long) index * step);
            index++;
            if (!date.isBefore(until)) return null;
            if (!date.isBefore(today) && (bought == null || date.isAfter(bought))) return date;
        }
    }
}
