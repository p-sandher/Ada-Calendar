--  Program Name: cal
--  Author: Puneet Sandher (1174249)
--  Course: CIS3190

--  This program prints the annual calendar in English or French for any year in the Gregorian calendar.

--  Libraries
with Ada.Text_IO; use Ada.Text_IO;
with ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO; use Ada.Strings.Unbounded.Text_IO;


procedure cal is
    year, firstday, lang : integer;
    type calendarArray is array(1..24, 1..21) of integer;
    calendar : calendarArray;
    twoBlanks : constant string := "  ";
    threeBlanks : constant string := "   ";
    fourBlanks : constant string := "    ";

    --  isvalid confirms if a user inputed year is in range of the Gregorian calendar. Returns True or False.
    function isvalid(year : in integer) return boolean is
    begin

    if year >= 1582 then 
        return True;
    else 
        return False;
    end if;

    end isvalid;

    --  leap year is a function checks if a year is a leap year. Returns True or False.
    function leapyear(year : in integer) return boolean is
    begin

    if year mod 100 = 0 and then year mod 400 = 0 then 
        return True;
    
    elsif year mod 100 /= 0 and then year mod 4 = 0 then
        return True;
    
    else 
        return False;
    end if;

    end leapyear;

    --  readcalinfo prompts the year to enter langauge preference and a year.
    procedure readcalinfo(year: out integer; firstday: out integer; lang: out integer ) is
    y : integer;

    begin
        --  Prompt user for preferred language, until valid option is given.
        loop
            begin
                put("Enter preferred language. Entrez la langue préférée. (English=0, French=1): "); 
                get(lang);
                if lang = 0 or else lang = 1 then 
                    exit;
                else 
                    skip_line; 
                    put("Invalid language option. Must be an integer within the range of options. Try again");
                    new_line;
                    put("Option de langue non valide. Doit être un nombre entier compris dans la plage d'options. Essayer à nouveau");
                    new_line;
                end if;
                exception
                    when data_error=>
                        skip_line; 
                        put("Invalid language option. Must be an integer. Try again");
                        new_line; 
                        put("Option de langue non valide. Doit être un entier. Essayer à nouveau");
                        new_line; 
            end;
        end loop;

        --  Prompt user for year, until valid option is given.
        loop
            begin
                if lang = 0 then
                    put("Enter the year: "); 
                else 
                    put("Entrez l'année :"); 
                end if;
                get(year);
                if isvalid(year) then
                    exit;
                else
                    skip_line; 
                    if lang = 0 then
                        put("Invalid year. Please enter a year within range of the Gregorian calendar. Try again.");
                    else 
                        put("Année invalide. Veuillez saisir une année comprise dans le calendrier grégorien. Essayer à nouveau.");
                    end if;
                    new_line;
                end if;
                exception
                    when data_error=>
                        skip_line; 
                        if lang = 0 then
                            put("Invalid year. Please enter a year within range of the Gregorian calendar. Try again.");
                        else 
                            put("Année invalide. Veuillez saisir une année comprise dans le calendrier grégorien. Essayer à nouveau.");
                        end if;
                        new_line;
            end;
        end loop;

        --  Determine what day of the week the year starts
        y := year - 1;
        firstday := (36 + y + (y / 4) - (y / 100) + (y / 400)) mod 7;

    end readcalinfo;

    --  numdaysinmonth returns an integer of how many days a specific month in the year has
    function numdaysinmonth(month : in integer; year : in integer) return integer is
    daysInMonth : integer;

    begin

        if month = 2 and then leapyear(year) then 
            daysInMonth := 29;
        elsif month = 2 then 
            daysInMonth := 28; 
        elsif month = 1 or  month = 3 or  month = 5 or  month = 7 or  month = 8 or  month = 10 or  month = 12 then
            daysInMonth := 31;
        else 
            daysInMonth := 30;
        end if;
        return daysInMonth;

    end numdaysinmonth;

    --  buildcalendar returns a 2D calendar array of the order of the days of the week for each row
    procedure buildcalendar (year : in integer; firstday: in out integer; calendar: out calendarArray) is

    rowCount, colCount, day, firstDayCount, daysInMonth  : integer;

    begin 

    --  Initialize calendar array to 0
    for i in 1..24 loop
        for j in 1..21 loop
            calendar(i,j) := 0; 
        end loop;
    end loop;

    colCount:=0;
    rowCount:=0;

    --  Iterate through each month and store the corresponding day in the calendar array
    for m in 1..12 loop
        daysInMonth := numdaysinmonth(m, year);
        firstDayCount := 0;
        day := 1;

        for i in 1..6 loop --iterate through each week
            for j in 1..7 loop -- iterate through each day
                
                --  Empty days at the beginning of the first week are initalized to 0
                if i = 1 and j <= (firstday) then
                    calendar((i+rowCount), j+colCount) := 0;

                elsif day <= daysInMonth then 
                    
                    --  Calculate the first day for the next month
                    if day = daysInMonth then 
                        firstDayCount:= j; 
                    end if;
                    calendar((i+rowCount), j+colCount) := day;
                    day := day + 1;

                --  Empty days at the end of the last week are initalized to 0
                else 
                    calendar(i+rowCount, j+colCount) := 0;
                end if;
            end loop;
        end loop;
        
        --  Increment month row for calendar array
        if m mod 3 = 0 then 
            rowCount := (rowCount + 6) mod 24; 
        end if;
        
        --  increment week column for calendar array
        colCount := (colCount + 7) mod 21;
        firstday := firstDayCount;

        if firstday = 7 then 
            firstday := 0;
        end if;

    end loop;

end buildcalendar;

--  stringconvert takes a string and converts it to an unbounded string 
--  This code is inspired by from https://craftofcoding.wordpress.com/2021/01/13/coding-ada-strings-iii-arrays-of-strings/
function stringconvert(stringToConvert : String) return unbounded_string renames ada.strings.unbounded.to_unbounded_string;

--  printrow heading prints each month and the days of the week
procedure printrowheading(lang : in integer; row: in integer ) is
    
    weekSpaceTotal : constant integer := 32;
    monthLength, spacing: integer;  

    type days is array(1..7) of string(1..2);
    type months is array(1..4, 1..3) of unbounded_string;

    enDays : constant days := ("Su","Mo","Tu","We","Th","Fr", "Sa");
    frDays : constant days := ("Di","Lu","Ma","Me","Je","Ve","Sa");

    enMonths : constant months := ((stringconvert("January"),stringconvert("February"),stringconvert("March")),(stringconvert("April"),stringconvert("May"), stringconvert("June")), (stringconvert("July"), stringconvert("August"), stringconvert("September")), (stringconvert("October"), stringconvert("November"), stringconvert("December")));
    frMonths : constant months := ((stringconvert("janvier"),stringconvert("février"),stringconvert("mars")),(stringconvert("avril"),stringconvert("mai"), stringconvert("juin")), (stringconvert("juillet"), stringconvert("août"), stringconvert("septembre")), (stringconvert("octobre"), stringconvert("novembre"), stringconvert("décembre")));  

    begin 

    new_line;

    --- iterate through specific row in month
    for i in months'Range(2) loop

        --  print months in English or French 
        --  padding between each month is calculate for consistent spacing
        if lang = 0 then
                monthLength := length(enMonths(row, i));
                spacing := (weekSpaceTotal - monthLength) / 2;

                for i in 1..spacing loop 
                    put(" ");
                end loop;

                put(enMonths(row, i) & " ");

                for i in 1..spacing loop 
                    put(" ");
                end loop;

                put(fourBlanks);
            else 
                monthLength := length(frMonths(row, i));
                spacing := (weekSpaceTotal - monthLength) / 2;

                for i in 1..spacing loop 
                    put(" ");
                end loop;

                put(frMonths(row, i) & " ");

                for i in 1..spacing loop 
                    put(" ");
                end loop;

                put(fourBlanks);
        end if;
    end loop;
    
    new_line;
    
    --  print the days of the week in English or French for three months in a row
    --  print with equal and consistent spacing with the month header
    for i in 1..3 loop
        for j in Days'Range loop
            
            if lang = 0 then
                put(enDays(j));
            else 
                put(frDays(j));
            end if;

            put(threeBlanks);
        end loop;
        put(twoBlanks);
    end loop;

end printrowheading;

--  printrowmonth displays all the rows in the month
procedure printrowmonth(calendar: in calendarArray; lang: in integer ) is 
    row : integer := 1;
    weekCount : integer := 0;

    begin 

    for i in 1..24 loop --iterate through each row in the calendar array
        
        --  print month and week heading for each month row
        if weekCount mod 6 = 0 then 
            printrowheading(lang, row);
            row := row + 1;
        end if;

        new_line;

        for j in 1..21 loop --iterate through each column in the calendar array
            
            --  Each day is printed, with consistent and equal spacing 
            if j = 8 then 
                put(threeBlanks);
            elsif j = 15 then 
                put(twoBlanks);
            end if;

            -- if the element is 0, print a space
            if calendar(i,j) = 0 then 
                put(" ");
            else
                put(calendar(i,j), 0);
            end if;

            if calendar(i,j) < 10 then 
                put(fourBlanks);
            else 
                put(threeBlanks);
            end if;

        end loop;
        weekCount := weekCount + 1;
        
    end loop;

end printrowmonth;

--  banner prints a large banner of the calendar year
procedure banner(year : in integer; indent: in integer) is 
    
    dataFile : constant string := "years.txt";
    eighteenBlanks : constant string := "                  ";
    --  tenBlanks : constant string := "           ";
    infp : file_type;
    yearDigits: array (1 .. 4) of integer;
    banner: array(1..10, 1..10) of string(1..9);
    line : string(1..9);

    begin 

    --  get each digit in the year
    yearDigits(1) := year / 1000;
    yearDigits(2) := (year / 100) mod 10;
    yearDigits(3) := (year / 10) mod 10;
    yearDigits(4) := year mod 10;

    --  Open datafile with number text font
    begin
        open(infp, in_file, dataFile);
    exception 
        when Name_Error =>
            put("years.txt is data file that is not found.");
            raise;

        when Use_Error =>
            put("years.txt is data file that you don't have permissions for.");
            raise;
    end;
    new_line;

    --  store each line in the textfile for each number in the banner array
    for i in 1..10 loop
        for j in 1..10 loop
            line := get_line (infp);
            banner(i, j) := line;
        end loop;
    end loop;
    
    --  display each number row by row
    for i in 1..10 loop 
        put(eighteenBlanks);
        for j in 1..4 loop 
            put(banner((yearDigits(j))+1, i));
            for i in 1..indent loop
                put(" ");
            end loop;
            --  put(tenBlanks);
        end loop;
        new_line;
    end loop;

    close(infp);

end banner;


begin
    put("Annual Calendar Generator / Générateur de calendrier annuel");
    new_line;
    put("Enter the fields below to generate a calendar / Entrez les champs ci-dessous pour générer un calendrier.");
    new_line;
    readcalinfo(year, firstday, lang);
    banner(year, 10);
    buildcalendar(year, firstday, calendar);
    printrowmonth(calendar, lang);
end cal;

