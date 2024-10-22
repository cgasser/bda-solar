﻿using System;
using System.Collections.Generic;
using System.Text;
using System.Linq;

namespace DataAccess.Slc
{
    public class PvLine
    {
        public string RawLine { get; set; }
        public DateTime FileDate { get; set; }

        public DateTimeOffset Timestamp { get; set; }
        public double TimestampUnix { get; set; }
        public decimal Power1 { get; set; }
        public decimal Power2 { get; set; }

        private DateTime unixMin = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        public void Parse(char separator)
        {
            string[] cols = RawLine.Split(separator);
            DateTimeOffset lineTimestamp = DateTimeOffset.Parse(cols.ElementAtOrDefault(0));

            Timestamp = new DateTime(FileDate.Year, FileDate.Month, FileDate.Day, lineTimestamp.Hour, lineTimestamp.Minute, 0);
            TimestampUnix = (Timestamp - unixMin).TotalSeconds;
            Power1 = decimal.TryParse(cols.ElementAtOrDefault(1), out decimal tmp1) ? tmp1 : default(decimal);
            Power2 = decimal.TryParse(cols.ElementAtOrDefault(2), out decimal tmp2) ? tmp2 : default(decimal);
        }

        public string Print(string timestampFormat)
        {
            return $"{Timestamp.LocalDateTime.ToString(timestampFormat)} {Power1:N3} {Power2:N3}";
        }
    }
}
