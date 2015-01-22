class NextLeapYear {
    int year;

    NextLeapYear(this.year);

    NextLeapYear next() {
        if (isLeap(year)) {
            return this;
        }

        int differenceToLeap = 4 - (year % 4);
        int next = year + differenceToLeap;
        if (!isLeap(next)) {
            next += 4;
        }

        return new NextLeapYear(next);
    }

    boolean isLeap(candidateYear) {
        if (candidateYear % 100 == 0) {
            return false;
        }

        return candidateYear % 4 == 0;
    }

}
