using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Linq;
using DataAccess.Slc;
using System.Text.RegularExpressions;
using System.Globalization;

namespace DataAccess.Raw
{
    internal class BirchliFile
    {
        public int FirstLineNo { get; set; } = 9;
        public char Separator { get; set; } = ';';
        public string DatePattern { get; set; } = @"(\d){2}-(\d){2}-(\d){2}";

        public string Folder { get; set; }
        public string FileName { get; set; }
        public DateTime FileDate { get; set; }

        public IEnumerable<string> RawLines { get { return Lines.Select(line => line.RawLine); } }
        public List<PvLine> Lines { get; set; }

        public void Read()
        {
            FileDate = DateTime.ParseExact(Regex.Match(FileName, DatePattern).Value, "yy-MM-dd", CultureInfo.InvariantCulture);

            var allLines = File.ReadAllLines(Path.Combine(Folder, FileName), Encoding.UTF8);

            Lines = allLines.Skip(FirstLineNo).TakeWhile(line => !string.IsNullOrWhiteSpace(line)).Select(line => new PvLine { RawLine = line, FileDate = FileDate }).ToList();
        }

        public void Parse()
        {
            foreach (var line in Lines)
            {
                line.Parse(Separator);
            }
        }
    }
}
