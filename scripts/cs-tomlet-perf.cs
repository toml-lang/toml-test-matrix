using System.Globalization;
using Tomlet;
using Tomlet.Models;

public class TomlynDecoder {
     public static void Main(string[] args) {
        string t = File.ReadAllText(args[0]);
        TomlDocument doc;
        System.Diagnostics.Stopwatch? watch = null;
        try {
            watch = System.Diagnostics.Stopwatch.StartNew();
            doc = new TomlParser().Parse(t);
            watch.Stop();
        } catch (Exception exc) {
            Console.Error.WriteLine(exc);
            Environment.Exit(1);
        }

        Console.WriteLine($"{watch.Elapsed.Milliseconds / 1000.0}");
    }
}
