CLS

_TITLE "PixelArt by Andrej"

main:

DIM released AS STRING
DIM projectStartDate AS STRING
DIM developer AS STRING
DIM developed AS STRING
DIM version AS STRING

version = "v1.9"

SCREEN _NEWIMAGE(1080, 720, 32) ' 136x44 text
_FULLSCREEN

DIM keyin AS STRING
DIM new_dir AS STRING
DIM new_dir_mid AS STRING
DIM lastProject AS STRING

DIM timeInd AS STRING
DIM timeFormat AS STRING
timeFormat = "12"

r = 255: g = 255: b = 255

remove = 0

DIM copyrightEnd AS STRING
copyrightEnd = MID$(DATE$, 7, 4)

DO

    remove = remove + 1

    COLOR _RGB(r, g, b)
    LOCATE 15, 64: PRINT "PixelArt"
    LOCATE 16, 64: PRINT "  " + version + "  "

    edition = 1

    LOCATE 38, 52: PRINT "(C) Copyright Andrej, 2017-"; copyrightEnd; "."
    LOCATE 39, 58: PRINT "All rights reserved."

    LOCATE 43, 38: PRINT "Developed in Modrica, from January 24th to March 17th, 2020."

    IF remove = 55 THEN
        r = r - 1: g = g - 1: b = b - 1
        remove = 0
    END IF

LOOP UNTIL r + g + b <= 0

CLS

IF _FILEEXISTS("pixelart.dat") = 0 THEN

    COLOR _RGB(255, 255, 255)

    LOCATE 1, 1: PRINT "No directory found."
    LOCATE 2, 1: PRINT "Please enter new directory."
    LOCATE 3, 1: PRINT "(Leave blank if you want to use the current working directory)"
    LOCATE 5, 1: INPUT "Location:", new_dir_mid

    FOR i = 1 TO LEN(new_dir_mid)
        IF MID$(new_dir_mid, i, 1) = " " THEN
            new_dir = new_dir + "\"
            GOTO skip_dir
        END IF

        new_dir = new_dir + MID$(new_dir_mid, i, 1)
        skip_dir:
    NEXT i

    frames = 0
    lastProject = ""
    timeFormat = "12"
    autoSaveBlockSize = 3

    OPEN "pixelart.dat" FOR OUTPUT AS #1
    WRITE #1, frames
    WRITE #1, new_dir
    WRITE #1, lastProject
    WRITE #1, timeFormat
    WRITE #1, autoSaveBlockSize
    CLOSE #1
END IF

OPEN "pixelart.dat" FOR INPUT AS #1
INPUT #1, frames
INPUT #1, new_dir
INPUT #1, lastProject
INPUT #1, timeFormat
INPUT #1, autoSaveBlockSize
CLOSE #1

IF new_dir <> "" THEN
    CHDIR new_dir
END IF

r = 0
g = 0
b = 0

DIM artname AS STRING
DIM artsize AS INTEGER

DIM rcol(4100) AS INTEGER
DIM gcol(4100) AS INTEGER
DIM bcol(4100) AS INTEGER

blocksize = 20

x1 = 0
x2 = 0
y1 = 0
y2 = 0

DEFINT A-Z

loadAutoSaveDrawing = 1
showCursor = 1
showGrid = 0

DIM day AS STRING
DIM month AS STRING
DIM year AS STRING

DIM monthName(12) AS STRING
monthName(1) = "Jan": monthName(2) = "Feb": monthName(3) = "Mar": monthName(4) = "Apr": monthName(5) = "May": monthName(6) = "Jun"
monthName(7) = "Jul": monthName(8) = "Aug": monthName(9) = "Sep": monthName(10) = "Oct": monthName(11) = "Nov": monthName(12) = "Dec"

DIM hour AS STRING
DIM minute AS STRING

DIM suffix AS STRING

CONST cirY = 10

CLS
DO

    back:

    OPEN "pixelart.dat" FOR INPUT AS #1
    INPUT #1, frames
    INPUT #1, new_dir
    INPUT #1, lastProject
    INPUT #1, timeFormat
    INPUT #1, autoSaveBlockSize
    CLOSE #1

    IF frames > 0 THEN
        _LIMIT frames
    END IF

    DO WHILE _MOUSEINPUT

        mx = _MOUSEX
        my = _MOUSEY

        IF _MOUSEBUTTON(1) = -1 THEN
            button = 1
        END IF

        IF _MOUSEBUTTON(2) = -1 THEN
            button = 2
        END IF

        IF _MOUSEBUTTON(3) = -1 THEN
            button = 3
        END IF

        IF change <> 0 THEN

            IF mx < 0 THEN
                mx = 0
            END IF

            IF mx > 255 THEN
                mx = 255
            END IF

        END IF

    LOOP

    IF button = 3 OR keyin = "m" THEN
        IF showCursor = 1 THEN
            showCursor = 0
            last_time = 1
        END IF

        IF showCursor = 0 AND last_time = 0 THEN
            showCursor = 1
        END IF

        last_time = 0
    END IF

    IF loadDrawing = 1 AND active = 0 THEN
        IF (mx >= drawx AND my >= drawy) AND (mx <= drawx + (artsize + 2) * autoSaveBlockSize AND my <= 615) THEN
            ' if the mouse is inside drawing : do nothing
        ELSE
            COLOR _RGB(0, 0, 0)
            LOCATE 42, 17: PRINT "This deletes messages"

            loadMessage = 0
        END IF
    END IF

    IF loadDrawing = 1 AND active = 0 THEN
        drawx = 127
        drawy = 615 - ((artsize + 2) * autoSaveBlockSize)

        IF (mx >= drawx AND my >= drawy) AND (mx <= drawx + (artsize + 2) * autoSaveBlockSize AND my <= 615) THEN
            IF loadMessage = 0 THEN
                COLOR _RGB(255, 255, 255)
                LOCATE 42, 17: PRINT "* Left-click to load."
            END IF

            IF button = 1 THEN
                GOTO loadAutoSave
            END IF
        END IF

    END IF

    drawx = 300
    drawy = 10

    xpoz = FIX((mx - drawx) / blocksize) + 1
    ypoz = FIX((my - drawy) / blocksize) + 1

    keyin = LCASE$(INKEY$)

    IF keyin = "q" THEN
        exitProgram:

        day = MID$(DATE$, 4, 2)
        month = MID$(DATE$, 1, 2)
        year = MID$(DATE$, 7, 4)

        IF active = 1 THEN

            OPEN "autosave.dat" FOR OUTPUT AS #1
            WRITE #1, day
            WRITE #1, month
            WRITE #1, year
            WRITE #1, artname
            WRITE #1, artsize
            WRITE #1, blocksize
            CLOSE #1

            OPEN "autosave.pxa" FOR OUTPUT AS #1
            FOR i = 1 TO artsize * artsize
                WRITE #1, rcol(i)
                WRITE #1, gcol(i)
                WRITE #1, bcol(i)
            NEXT i
            CLOSE #1

        END IF

        SYSTEM
    END IF

    IF (active = 0) THEN
        COLOR _RGB(255, 255, 255)
        LOCATE 2, 61: PRINT "PixelArt ";
    END IF

    IF (active = 1) THEN
        COLOR _RGB(255, 255, 255)
        LOCATE 1, 1: PRINT "PixelArt ";
    END IF

    COLOR _RGB(255, 255, 65)
    PRINT version

    IF active = 0 THEN
        COLOR _RGB(255, 255, 255)

        LINE (380, 50)-(680, 110), _RGB(255, 255, 255), B

        LOCATE 5, 50: PRINT "* Press space to start new project."
        LOCATE 6, 54: PRINT "* Press L to load project."

        IF (_FILEEXISTS("autosave.dat") = -1) THEN

            suffix = "th"

            IF day = "1" THEN
                suffix = "st"
            END IF
            IF day = "2" THEN
                suffix = "nd"
            END IF
            IF day = "3" THEN
                suffix = "rd"
            END IF

            IF loadDate = 0 THEN


                OPEN "autosave.dat" FOR INPUT AS #1
                INPUT #1, day
                INPUT #1, month
                INPUT #1, year
                INPUT #1, artname
                INPUT #1, artsize
                INPUT #1, blocksize
                CLOSE #1

                loadDate = 1

            END IF

            IF loadAutoSaveDrawing = 1 THEN
                IF loadDrawing = 0 THEN

                    OPEN "autosave.pxa" FOR INPUT AS #1
                    FOR i = 1 TO artsize * artsize
                        INPUT #1, rcol(i)
                        INPUT #1, gcol(i)
                        INPUT #1, bcol(i)
                    NEXT i
                    CLOSE #1

                    loadDrawing = 1

                END IF
            END IF

            LOCATE 40, 17: PRINT "* Autosave project found!"; " (from: "; monthName(VAL(month)); " "; day + suffix; ", "; year; ")"
            LOCATE 41, 17: PRINT "* Press A to continue working."

            IF loadDrawing = 1 THEN
                drawx = 127
                drawy = 615 - ((artsize + 2) * autoSaveBlockSize)
                i = 1

                FOR x = 0 TO artsize + 1

                    FOR y = 0 TO artsize + 1

                        IF (x < artsize + 1 AND y < artsize + 1) AND (x > 0 AND y > 0) THEN
                            LINE (drawx, drawy)-(drawx + autoSaveBlockSize, drawy + autoSaveBlockSize), _RGB(rcol(i), gcol(i), bcol(i)), BF
                            i = i + 1
                        END IF

                        IF (x = 0 OR y = 0) OR (x > artsize OR y > artsize) THEN
                            LINE (drawx, drawy)-(drawx + autoSaveBlockSize, drawy + autoSaveBlockSize), _RGB(255, 255, 255), BF
                        END IF


                        drawx = drawx + autoSaveBlockSize
                    NEXT y

                    drawx = 127
                    drawy = drawy + autoSaveBlockSize
                NEXT x

            END IF

        END IF

    END IF

    COLOR _RGB(255, 255, 255)

    i = 0

    IF active = 1 AND preview = 0 THEN

        day = MID$(DATE$, 4, 2)
        month = MID$(DATE$, 1, 2)
        year = MID$(DATE$, 7, 4)

        ' exit:
        circleR = 5

        disX1 = mx
        disY1 = my
        disX2 = 1070
        disY2 = cirY

        IF disY2 > disY1 THEN
            SWAP disY1, disY2
        END IF

        IF disX2 > disX1 THEN
            SWAP disX1, disX2
        END IF

        sideA = disY1 - disY2
        sideB = disX1 - disX2

        distance = SQR((sideA * sideA) + (sideB * sideB))

        IF (circleR > distance) THEN

            IF button = 1 THEN
                GOTO exitProgram
            END IF

        END IF

        CIRCLE (1070, cirY), circleR, _RGB(255, 25, 25)
        PAINT STEP(0, 0), _RGB(255, 25, 25)


        ' save and exit :
        circleR = 5

        disX1 = mx
        disY1 = my
        disX2 = 1055
        disY2 = cirY

        IF disY2 > disY1 THEN
            SWAP disY1, disY2
        END IF

        IF disX2 > disX1 THEN
            SWAP disX1, disX2
        END IF

        sideA = disY1 - disY2
        sideB = disX1 - disX2

        distance = SQR((sideA * sideA) + (sideB * sideB))

        IF (circleR > distance) THEN

            IF button = 1 THEN
                exitAfterwards = 1
                GOTO saveDrawing
            END IF

        END IF

        CIRCLE (1055, cirY), circleR, _RGB(230, 230, 5)
        PAINT STEP(0, 0), _RGB(230, 230, 5)

        ' save :
        circleR = 5

        disX1 = mx
        disY1 = my
        disX2 = 1040
        disY2 = cirY

        IF disY2 > disY1 THEN
            SWAP disY1, disY2
        END IF

        IF disX2 > disX1 THEN
            SWAP disX1, disX2
        END IF

        sideA = disY1 - disY2
        sideB = disX1 - disX2

        distance = SQR((sideA * sideA) + (sideB * sideB))

        IF (circleR > distance) THEN

            IF button = 1 THEN
                GOTO saveDrawing
            END IF

        END IF


        CIRCLE (1040, cirY), circleR, _RGB(10, 225, 5)
        PAINT STEP(0, 0), _RGB(10, 225, 5)

        xDay = 128
        ' xMonth = 132
        ' xYear = 131

        IF (VAL(day)) < 10 THEN
            day = LTRIM$(RTRIM$(STR$(VAL(day))))
            xDay = 129
        END IF

        LOCATE 3, xDay: PRINT day; ".";
        LOCATE 3, 132: PRINT monthName(VAL(month));
        LOCATE 4, 131: PRINT year

        hour = MID$(TIME$, 1, 2)
        minute = MID$(TIME$, 4, 2)

        IF timeFormat = "24" THEN
            hour = MID$(TIME$, 1, 2)
            minute = MID$(TIME$, 4, 2)

            LOCATE 5, 129: PRINT hour; ":"; minute; "h"
        END IF

        IF timeFormat = "12" THEN
            hour = MID$(TIME$, 1, 2)
            minute = MID$(TIME$, 4, 2)

            IF VAL(hour) > 12 THEN
                timeInd = "PM"
                hour = LTRIM$(RTRIM$(STR$(VAL(hour) - 12)))
            ELSE
                timeInd = "AM"
            END IF

            xHour = 128
            IF (VAL(hour)) < 10 THEN
                xHour = 129
            END IF

            LOCATE 5, xHour: PRINT hour; ":"; minute; timeInd
        END IF

        LOCATE 3, 1: PRINT "Project: "; artname
        LOCATE 4, 1: PRINT "Size: "; artsize; "x"; artsize

        LOCATE 6, 1: PRINT "R:"; r; " G:"; g; " B:"; b; "  "

        COLOR _RGB(255, 255, 255)

        IF changeCol = 1 AND avoidCol = 0 AND nobgPaint = 0 THEN
            LOCATE 9, 1: PRINT "* Color replacement is acitve!"
            LINE (249, 123)-(271, 145), _RGB(255, 255, 255), B
            LINE (250, 124)-(270, 144), _RGB(chR, chG, chB), BF
        END IF

        IF nobgPaint = 1 AND avoidCol = 0 AND changeCol = 0 THEN
            LOCATE 9, 1: PRINT "* Background remove is active!"
        END IF

        IF avoidCol = 1 AND nobgPaint = 0 AND changeCol = 0 THEN
            LOCATE 9, 1: PRINT "* Avoiding collision is active!"
        END IF


        IF x1 > 0 AND y1 > 0 THEN

            maxX = 300 + ((artsize - 1) * blocksize)
            maxY = 10 + ((artsize - 1) * blocksize)

            IF x1 > maxX THEN
                x1 = maxX
            END IF
            IF y1 > maxY THEN
                y1 = maxY
            END IF

            IF x1 < 300 THEN
                x1 = 300
            END IF
            IF y1 < 10 THEN
                y1 = 10
            END IF

            xFill1 = FIX((x1 - drawx) / blocksize) + 1
            yFill1 = FIX((y1 - drawy) / blocksize) + 1

            IF xFill1 > artsize THEN
                xFill1 = artsize
            END IF
            IF yFill1 > artsize THEN
                yFill1 = artsize
            END IF

            IF xFill1 < 1 THEN
                xFill1 = 1
            END IF
            IF yFill1 < 1 THEN
                yFill1 = 1
            END IF

            IF (xFill1 > 0) AND (xFill1 < 65) AND (yFill1 > 0) AND (yFill1 < 65) AND fill = 0 THEN
                LOCATE 10, 1: PRINT "Start X and Y:"; FIX((x1 - drawx) / blocksize) + 1; ","; FIX((y1 - drawy) / blocksize) + 1
            END IF

        END IF

        IF x2 > 0 AND y2 > 0 THEN

            IF x2 > maxX THEN
                x2 = maxX
            END IF
            IF y2 > maxY THEN
                y2 = maxY
            END IF

            IF x2 < 300 THEN
                x2 = 300
            END IF
            IF y2 < 10 THEN
                y2 = 10
            END IF

            xFill2 = FIX((x2 - drawx) / blocksize) + 1
            yFill2 = FIX((y2 - drawy) / blocksize) + 1

            IF xFill2 > artsize THEN
                xFill2 = artsize
            END IF
            IF yFill2 > artsize THEN
                yFill2 = artsize
            END IF

            IF xFill2 < 1 THEN
                xFill2 = 1
            END IF
            IF yFill2 < 1 THEN
                yFill2 = 1
            END IF

            IF (xFill2 > 0) AND (xFill2 < 65) AND (yFill2 > 0) AND (yFill2 < 65) AND fill = 0 THEN
                LOCATE 11, 1: PRINT "End X and Y:"; FIX((x2 - drawx) / blocksize) + 1; ","; FIX((y2 - drawy) / blocksize) + 1
            END IF

        END IF

        ff = ff + 1
        IF TIMER - start! >= 1 THEN fps = ff: ff = 0: start! = TIMER

        COLOR _RGB(255, 255, 255)
        LOCATE 1, 17: PRINT "("; fps; "fps )   "

        LINE (184, 74)-(206, 96), _RGB(255, 255, 255), B
        LINE (185, 75)-(205, 95), _RGB(r, g, b), BF

        LINE (drawx - 1, drawy - 1)-(drawx + (blocksize * artsize) + 1, drawy + (blocksize * artsize) + 1), _RGB(255, 255, 255), B

        IF keyin = "o" THEN
            CLS
            GOTO options
        END IF

        IF keyin = "f" THEN

            drawx = 300
            drawy = 10

            x1 = FIX((x1 - drawx) / blocksize) + 1
            y1 = FIX((y1 - drawy) / blocksize) + 1

            x2 = FIX((x2 - drawx) / blocksize) + 1
            y2 = FIX((y2 - drawy) / blocksize) + 1

            IF (x1 > x2) THEN
                SWAP x1, x2
            END IF

            IF (y1 > y2) THEN
                SWAP y1, y2
            END IF

            fill = 1

        END IF


        FOR y = 1 TO artsize
            FOR x = 1 TO artsize
                i = i + 1

                IF fill = 1 AND avoidCol = 1 AND nobgPaint = 0 THEN
                    IF (x >= x1 AND x <= x2) AND (y >= y1 AND y <= y2) THEN

                        IF (rcol(i) = 0 AND gcol(i) = 0 AND bcol(i) = 0) THEN
                            rcol(i) = r
                            gcol(i) = g
                            bcol(i) = b
                            filled = filled + 1
                        END IF

                    END IF
                END IF

                IF fill = 1 AND changeCol = 1 AND nobgPaint = 0 AND avoidCol = 0 THEN
                    IF (x >= x1 AND x <= x2) AND (y >= y1 AND y <= y2) THEN

                        IF (rcol(i) = chR AND gcol(i) = chG AND bcol(i) = chB) THEN
                            rcol(i) = r
                            gcol(i) = g
                            bcol(i) = b
                            filled = filled + 1
                        END IF

                    END IF
                END IF

                IF fill = 1 AND nobgPaint = 1 AND avoidCol = 0 AND changeCol = 0 THEN
                    IF (x >= x1 AND x <= x2) AND (y >= y1 AND y <= y2) THEN

                        rcol(i) = -1
                        gcol(i) = -1
                        bcol(i) = -1
                        filled = filled + 1

                    END IF
                END IF

                IF fill = 1 AND nobgPaint = 0 AND avoidCol = 0 AND changeCol = 0 THEN

                    IF (x >= x1 AND x <= x2) AND (y >= y1 AND y <= y2) THEN
                        filled = filled + 1
                        IF nobgPaint = 0 THEN
                            rcol(i) = r
                            gcol(i) = g
                            bcol(i) = b
                        END IF
                    END IF

                END IF

                IF x = xpoz AND y = ypoz THEN
                    IF button = 1 AND nobgPaint = 0 AND avoidCol = 0 AND changeCol = 0 THEN
                        rcol(i) = r
                        gcol(i) = g
                        bcol(i) = b
                    END IF

                    IF button = 1 AND avoidCol = 1 THEN
                        IF (rcol(i) = 0 AND gcol(i) = 0 AND bcol(i) = 0) THEN
                            rcol(i) = r
                            gcol(i) = g
                            bcol(i) = b
                        END IF
                    END IF

                    IF button = 1 AND nobgPaint = 1 THEN
                        rcol(i) = -1
                        gcol(i) = -1
                        bcol(i) = -1
                    END IF

                    IF button = 1 AND changeCol = 1 THEN
                        IF (rcol(i) = chR AND gcol(i) = chG AND bcol(i) = chB) THEN
                            rcol(i) = r
                            gcol(i) = g
                            bcol(i) = b
                        END IF
                    END IF

                    IF button = 2 AND (rcol(i) <> -1 AND gcol(i) <> -1 AND bcol(i) <> -1) THEN
                        r = rcol(i)
                        g = gcol(i)
                        b = bcol(i)
                    END IF
                END IF

                IF (x1 <> 0 AND y1 <> 0) AND (x2 <> 0 AND y2 <> 0) THEN

                    IF (x >= xFill1 AND y = yFill1 AND x <= xFill2) OR (x >= xFill1 AND y = yFill2 AND x <= xFill2) OR (y >= yFill1 AND x = xFill1 AND y <= yFill2) OR (y >= yFill1 AND x = xFill2 AND y <= yFill2) THEN

                        LINE (drawx + showGrid, drawy + showGrid)-(drawx + blocksize - showGrid, drawy + blocksize - showGrid), _RGB(255, 255, 255), BF
                        filledPixel = 1
                    END IF

                END IF

                IF (x1 <> 0 AND y1 <> 0) AND (x2 = 0 AND y2 = 0) THEN

                    IF xpoz > artsize THEN
                        xpoz = artsize
                    END IF
                    IF ypoz > artsize THEN
                        ypoz = artsize
                    END IF

                    IF xpoz < 1 THEN
                        xpoz = 1
                    END IF
                    IF ypoz < 1 THEN
                        ypoz = 1
                    END IF


                    xFill1 = FIX((x1 - 300) / blocksize) + 1
                    yFill1 = FIX((y1 - 10) / blocksize) + 1

                    IF fill1I = 0 AND x = xFill1 AND y = yFill1 THEN
                        fill1I = i
                    END IF

                    IF (x >= xFill1 AND y = yFill1 AND x <= xpoz) OR (x >= xFill1 AND y = ypoz AND x <= xpoz) OR (y >= yFill1 AND x = xFill1 AND y <= ypoz) OR (y >= yFill1 AND x = xpoz AND y <= ypoz) OR (x >= xpoz AND y = yFill1 AND x < xFill1) OR (x >= xpoz AND y = ypoz AND x < xFill1) OR (y >= ypoz AND x = xFill1 AND y <= yFill1) OR (y >= ypoz AND x = xpoz AND y <= yFill1) THEN
                        LINE (drawx + showGrid, drawy + showGrid)-(drawx + blocksize - showGrid, drawy + blocksize - showGrid), _RGB(255, 255, 255), BF
                        drawFillArea = 1
                        filledPixel = 1
                    END IF

                END IF

                IF (x = xpoz AND y = ypoz) AND change = 0 AND drawFillArea = 0 AND showCursor = 1 THEN
                    LINE (drawx + showGrid, drawy + showGrid)-(drawx + blocksize - showGrid, drawy + blocksize - showGrid), _RGB(r, g, b), BF
                    filledPixel = 1
                END IF

                IF filledPixel = 0 THEN

                    IF (rcol(i) <> -1 AND gcol(i) <> -1 AND bcol(i) <> -1) THEN

                        LINE (drawx + showGrid, drawy + showGrid)-(drawx + blocksize - showGrid, drawy + blocksize - showGrid), _RGB(rcol(i), gcol(i), bcol(i)), BF

                    ELSE

                        LINE (drawx + showGrid, drawy + showGrid)-(drawx + blocksize - showGrid, drawy + blocksize - showGrid), _RGB(nobgCol, nobgCol, nobgCol), BF

                    END IF

                END IF

                drawFillArea = 0
                filledPixel = 0

                ' drawx = 300
                ' drawy = 10

                xFill1 = FIX((x1 - 300) / blocksize) + 1
                xFill2 = FIX((x2 - 300) / blocksize) + 1

                yFill1 = FIX((y1 - 10) / blocksize) + 1
                yFill2 = FIX((y2 - 10) / blocksize) + 1

                IF xFill2 < xFill1 AND xFill2 <> 0 THEN
                    SWAP xFill1, xFill2
                END IF

                IF yFill1 > yFill2 AND yFill2 <> 0 THEN
                    SWAP yFill1, yFill2
                END IF

                drawx = drawx + blocksize

            NEXT x


            drawx = 300
            drawy = drawy + blocksize

        NEXT y

        drawx = 300
        drawy = 10

        IF nobgCol = 0 AND time_left > fps THEN
            time_left = 0
            nobgCol = 255

            last_time = 1
        END IF

        IF nobgCol = 255 AND last_time = 0 AND time_left > fps THEN
            nobgCol = 0
            time_left = 0
        END IF

        time_left = time_left + 1
        last_time = 0

        IF keyin = "o" THEN
            gotoOptions:
            GOTO options
        END IF

        IF keyin = "p" THEN
            preview = 1
        END IF

        IF keyin = "i" THEN
            save = 1
        END IF

        IF saveSucces = 1 THEN
            saveSucces = 0
            COLOR _RGB(255, 255, 255)

            LOCATE 12, 1: PRINT "* Succesfully saved to bitmap."
            _DELAY 1.25

            COLOR _RGB(0, 0, 0)

            ' delete bitmap messages:
            LOCATE 12, 1: PRINT "This deletes messages by overlaying them with black text." ' delete bitmap message


        END IF

        IF fill = 1 AND save <> 1 THEN
            fill = 0

            LINE (300 + x1 + showGrid - 1, 10 + y1 + showGrid - 1)-(300 + x1 + blocksize - showGrid - 1, 10 + y1 + blocksize - showGrid - 1), _RGB(rcol(fill1I), gcol(fill1I), bcol(fill1I)), BF

            fill1I = 0
            x1 = 0
            x2 = 0
            y1 = 0
            y2 = 0

            COLOR _RGB(255, 255, 255)

            LOCATE 12, 1: PRINT "*"; filled; "pixel(s) painted."
            _DELAY 1.25

            COLOR _RGB(0, 0, 0)

            ' delete fill tool messages:
            LOCATE 10, 1: PRINT "This deletes messages by overlaying them with black text." ' delete x1,y1 message
            LOCATE 11, 1: PRINT "This deletes messages by overlaying them with black text." ' delete x2,y2 message
            LOCATE 12, 1: PRINT "This deletes messages by overlaying them with black text." ' delete filled message

            filled = 0

        END IF

        IF keyin = "c" AND nobgPaint = 0 AND avoidCol = 0 THEN
            IF changeCol = 0 THEN
                changeCol = 1
                last_time = 1

                chR = r
                chG = g
                chB = b
            END IF

            IF changeCol = 1 AND last_time = 0 THEN
                changeCol = 0

                COLOR _RGB(0, 0, 0)
                LOCATE 8, 1: PRINT "This deletes messages by overlaying them with black text." ' change color message
                LOCATE 9, 1: PRINT "This deletes messages by overlaying them with black text." ' change color message
                LOCATE 10, 1: PRINT "This deletes messages by overlaying them with black text." ' change color message

            END IF

            last_time = 0
        END IF

        IF keyin = "/" AND nobgPaint = 0 AND changeCol = 0 THEN
            IF avoidCol = 0 THEN
                avoidCol = 1
                last_time = 1
            END IF

            IF avoidCol = 1 AND last_time = 0 THEN
                avoidCol = 0

                COLOR _RGB(0, 0, 0)
                LOCATE 9, 1: PRINT "This deletes messages by overlaying them with black text." ' avoid collision message
            END IF

            last_time = 0
        END IF

        IF keyin = "*" AND avoidCol = 0 AND changeCol = 0 THEN
            IF nobgPaint = 0 THEN
                nobgPaint = 1
                last_time = 1
            END IF

            IF nobgPaint = 1 AND last_time = 0 THEN
                nobgPaint = 0

                COLOR _RGB(0, 0, 0)
                LOCATE 9, 1: PRINT "This deletes messages by overlaying them with black text." ' delete remove background message
            END IF

            last_time = 0
        END IF

        IF keyin = "v" THEN
            IF showGrid = 1 THEN
                showGrid = 0
                last_time = 1
            END IF

            IF showGrid = 0 AND last_time = 0 THEN
                showGrid = 1
                LINE (301, 11)-(300 + artsize * blocksize, 10 + artsize * blocksize), _RGB(0, 0, 0), BF
            END IF

            last_time = 0
        END IF
        IF keyin = "1" AND x1 = 0 AND y1 = 0 THEN
            x1 = mx
            y1 = my
        END IF

        IF keyin = "2" AND x1 > 0 AND y1 > 0 AND x2 = 0 AND y2 = 0 THEN
            x2 = mx
            y2 = my
        END IF

        IF keyin = "0" THEN
            x1 = 0
            x2 = 0

            y1 = 0
            y2 = 0

            COLOR _RGB(0, 0, 0)
            LOCATE 10, 1: PRINT "00000000000000000000000000000" ' delete x1, y1 message
            LOCATE 11, 1: PRINT "00000000000000000000000000000" ' delete x2, y2 message
            LOCATE 12, 1: PRINT "00000000000000000000000000000" ' delete filled message

        END IF

        IF keyin = "a" AND active = 1 THEN

            drawx = 300
            drawy = 10

            x1 = drawx
            y1 = drawy

            x2 = drawx + blocksize * (artsize - 1)
            y2 = drawy + blocksize * (artsize - 1)
        END IF


        i = 0

        IF keyin = "d" THEN
            GOTO showDialog
        END IF

        IF keyin = "s" AND active = 1 THEN

            saveDrawing:

            OPEN "pixelart.dat" FOR OUTPUT AS #1
            WRITE #1, frames
            WRITE #1, new_dir
            WRITE #1, lastProject
            WRITE #1, timeFormat
            WRITE #1, autoSaveBlockSize
            CLOSE #1

            OPEN artname + ".pxa" FOR OUTPUT AS #1
            WRITE #1, artname
            WRITE #1, artsize
            WRITE #1, blocksize

            FOR i = 1 TO artsize * artsize

                WRITE #1, rcol(i)
                WRITE #1, gcol(i)
                WRITE #1, bcol(i)
            NEXT i

            CLOSE #1

            IF exitAfterwards = 1 THEN
                exitAfterwards = 0
                GOTO exitProgram
            END IF

            LOCATE 43, 1: PRINT "* Saved ";
            COLOR _RGB(35, 255, 80): PRINT "succesfully."

            _DELAY 0.75

            CLS

        END IF

        COLOR _RGB(255, 255, 255)

        IF change = 0 THEN

            IF keyin = "r" THEN
                change = 1
            END IF

            IF keyin = "g" THEN
                change = 2
            END IF

            IF keyin = "b" THEN
                change = 3
            END IF

        END IF

        IF change <> 0 THEN
            IF mx < 0 THEN
                mx = 0
            END IF

            IF mx > 255 THEN
                mx = 255
            END IF

            LINE (0, 115)-(255, 125), _RGB(0, 0, 0), BF

            LINE (mx, 115)-(mx, 125), _RGB(255, 255, 255)
            LINE (0, 120)-(255, 120), _RGB(255, 255, 255)

            IF change = 1 THEN
                r = mx
            END IF

            IF change = 2 THEN
                g = mx
            END IF

            IF change = 3 THEN
                b = mx
            END IF


            IF button = 1 OR keyin = " " THEN
                change = 0
                CLS
            END IF

        END IF

    END IF

    IF keyin = "e" THEN
        r = 0
        g = 0
        b = 0
        CLS
    END IF

    IF keyin = "n" THEN ' start new project
        active = 0
        LINE (0, 0)-(1080, 720), _RGB(0, 0, 0), BF
    END IF

    IF keyin = " " AND active = 0 THEN
        active = 1

        IF loadDrawing = 1 THEN
            drawx = 127
            drawy = 615 - ((artsize + 2) * autoSaveBlockSize)

            LINE (drawx, drawy)-(drawx + 400, 700), _RGB(0, 0, 0), BF
        END IF

        IF _FILEEXISTS("autosave.dat") = -1 THEN
            KILL "autosave.dat"
        END IF

        IF _FILEEXISTS("autosave.pxa") = -1 THEN
            KILL "autosave.pxa"
        END IF

        LOCATE 16, 50: PRINT "Please enter project name without extension."
        LOCATE 15, 50: INPUT "1. PixelArt name: ", artname

        IF artname = "autosave" OR LEN(artname) < 3 OR LEN(artname) > 25 THEN
            active = 0
            GOTO active_skip
        END IF

        LOCATE 19, 50: PRINT "Maximum picture size is 64 (64x64)."
        LOCATE 20, 50: PRINT "Suggestion: set 32 or 64 for picture size."
        LOCATE 18, 50: INPUT "2. Picture size: ", artsize

        IF artsize < 8 OR artsize > 64 THEN
            active = 0
            GOTO active_skip
        END IF

        maxBlocksizeX = FIX((1080 - 300) / artsize)
        maxBlocksizeY = FIX((720 - 10) / artsize)

        IF maxBlocksizeX > maxBlocksizeY THEN
            maxblocksize = maxBlocksizeY
        ELSE
            maxblocksize = maxBlocksizeX
        END IF

        LOCATE 23, 50: PRINT "Maximum pixel size is:"; maxblocksize; ""
        LOCATE 24, 50: PRINT "Suggestion: use the maximum pixel size."
        LOCATE 25, 50: INPUT "3. Your desired pixel size:", blocksize

        CLS

        IF blocksize > maxblocksize THEN
            active = 0
            GOTO active_skip
        END IF

        OPEN artname + ".pxa" FOR OUTPUT AS #1

        FOR i = 0 TO artsize * artsize
            IF i = 0 THEN
                WRITE #1, artname
                WRITE #1, artsize
                WRITE #1, blocksize
            END IF

            IF i > 0 THEN
                WRITE #1, rcol(i)
                WRITE #1, gcol(i)
                WRITE #1, bcol(i)
            END IF

        NEXT i

        CLOSE #1

        active_skip:
        CLS

    END IF

    IF keyin = "l" AND active = 0 THEN

        IF loadDrawing = 1 THEN
            drawx = 127
            drawy = 615 - ((artsize + 2) * autoSaveBlockSize)

            LINE (drawx, drawy)-(drawx + 400, 700), _RGB(0, 0, 0), BF
        END IF

        active = 1

        LOCATE 15, 50: INPUT "* Enter pixel art name: ", artname

        CLS

        IF artname = "autosave" THEN
            GOTO load_skip
        END IF

        IF _FILEEXISTS(artname + ".pxa") = 0 THEN
            active = 0
            GOTO load_skip
        END IF

        OPEN artname + ".pxa" FOR INPUT AS #1
        INPUT #1, artname
        INPUT #1, artsize
        INPUT #1, blocksize
        CLOSE #1

        OPEN artname + ".pxa" FOR INPUT AS #1

        FOR i = 0 TO artsize * artsize

            IF i = 0 THEN
                INPUT #1, artname
                INPUT #1, artsize
                INPUT #1, blocksize
            END IF

            IF i > 0 THEN
                INPUT #1, rcol(i)
                INPUT #1, gcol(i)
                INPUT #1, bcol(i)
            END IF
        NEXT i

        CLOSE #1

        load_skip:
        CLS

        IF _FILEEXISTS("autosave.dat") = -1 THEN
            KILL "autosave.dat"
        END IF

        IF _FILEEXISTS("autosave.pxa") = -1 THEN
            KILL "autosave.pxa"
        END IF

    END IF

    IF keyin = "a" AND active = 0 THEN
        loadAutoSave:

        active = 1

        OPEN "autosave.dat" FOR INPUT AS #1
        INPUT #1, day
        INPUT #1, month
        INPUT #1, year
        INPUT #1, artname
        INPUT #1, artsize
        INPUT #1, blocksize
        CLOSE #1

        OPEN "autosave.pxa" FOR INPUT AS #1
        FOR i = 1 TO artsize * artsize
            INPUT #1, rcol(i)
            INPUT #1, gcol(i)
            INPUT #1, bcol(i)
        NEXT i
        CLOSE #1

        KILL "autosave.dat"
        KILL "autosave.pxa"

        CLS

    END IF

    IF save = 1 THEN

        save = 0
        SCREEN _NEWIMAGE(artsize, artsize, 32)

        CLS

        FOR y = 0 TO artsize - 1
            FOR x = 0 TO artsize - 1
                i = i + 1

                IF (rcol(i) <> -1 AND gcol(i) <> -1 AND bcol(i) <> -1) THEN

                    PSET (startx + x, starty + y), _RGB(rcol(i), gcol(i), bcol(i))

                END IF
            NEXT x
        NEXT y

        saveSucces = 1
        Save32 0, 0, artsize - 1, artsize - 1, 0, artname + ".BMP"

    END IF

    IF preview = 1 THEN

        draw_again:

        CLS

        previewx = 320
        previewy = 240

        SCREEN _NEWIMAGE(previewx, previewy, 32)

        FOR y = 0 TO artsize - 1
            FOR x = 0 TO artsize - 1
                i = i + 1

                IF (rcol(i) <> -1 AND gcol(i) <> -1 AND bcol(i) <> -1) THEN

                    PSET (startx + x, starty + y), _RGB(rcol(i), gcol(i), bcol(i))

                END IF
            NEXT x
        NEXT y


        DO
            keyin = INKEY$

            DO WHILE _MOUSEINPUT
                mx = _MOUSEX
                my = _MOUSEY

                IF _MOUSEBUTTON(1) = -1 THEN
                    move = 1
                END IF
            LOOP

            IF move = 1 THEN
                move = 0
                i = 0
                keyin = ""
                startx = mx
                starty = my
                GOTO draw_again
            END IF

            IF keyin <> "" THEN
                preview = 0

                SCREEN _NEWIMAGE(1080, 720, 32)
                GOTO preview_esc
            END IF

        LOOP

    END IF

    preview_esc:
    button = 0
LOOP

options:
CLS

OPEN "pixelart.dat" FOR INPUT AS #1
INPUT #1, frames
INPUT #1, new_dir
INPUT #1, lastProject
CLOSE #1

DO

    IF frames <> 0 THEN
        _LIMIT frames
    END IF

    keyin = INKEY$

    IF keyin = " " THEN
        IF change = 2 THEN
            change = 0
            LINE (185, 340)-(275, 360), _RGB(0, 0, 0), BF
        END IF
        IF change = 3 THEN
            change = 0
            LINE (185, 410)-(345, 420), _RGB(0, 0, 0), BF
        END IF
    END IF

    button = 0
    DO WHILE _MOUSEINPUT
        mx = _MOUSEX
        my = _MOUSEY

        IF _MOUSEBUTTON(1) = -1 THEN
            button = 1
        END IF

        IF change = 2 THEN
            IF mx < 187 THEN
                mx = 187
            END IF
            IF mx > 275 THEN
                mx = 275
            END IF
        END IF

        IF change = 3 THEN
            IF mx < 185 THEN
                mx = 185
            END IF
            IF mx > 345 THEN
                mx = 345
            END IF
        END IF

    LOOP

    COLOR _RGB(255, 255, 255)
    LOCATE 2, 61: PRINT "PixelArt ";

    COLOR _RGB(255, 255, 65)
    PRINT version

    COLOR _RGB(255, 255, 255)
    LINE (350, 50)-(720, 110), _RGB(255, 255, 255), B
    LOCATE 5, 64: PRINT "Settings"
    LOCATE 6, 46: PRINT "Please click on the ones you want to change."

    ' timeformat
    ' autoSaveBlocksize
    ' fps
    ' directory
    ' see credits

    setR1 = 255: setG1 = 255: setB1 = 255
    setR2 = 255: setG2 = 255: setB2 = 255
    setR3 = 255: setG3 = 255: setB3 = 255
    setR4 = 255: setG4 = 255: setB4 = 255

    setR = 255: setG = 255: setB = 255 ' exit

    IF mx >= 520 AND mx <= 550 THEN
        IF my >= 673 AND my <= 683 THEN
            setR = 55
            setG = 255
            setB = 0

            IF button = 1 THEN
                OPEN "pixelart.dat" FOR OUTPUT AS #1
                WRITE #1, frames
                WRITE #1, new_dir
                WRITE #1, lastProject
                WRITE #1, timeFormat
                WRITE #1, autoSaveBlockSize
                CLOSE #1

                CLS
                GOTO back
            END IF
        END IF
    END IF

    IF mx >= 153 AND mx <= 173 THEN
        ' color _RGB(55, 255, 0)

        IF my >= 177 AND my <= 190 AND change = 0 THEN
            setR1 = 55
            setG1 = 255
            setB1 = 0

            IF button = 1 THEN
                change = 1
            END IF
        END IF

        IF my >= 275 AND my <= 285 AND change = 0 THEN
            setR2 = 55
            setG2 = 255
            setB2 = 0

            IF button = 1 THEN
                change = 2
            END IF
        END IF

        IF my >= 370 AND my <= 380 AND change = 0 THEN
            setR3 = 55
            setG3 = 255
            setB3 = 0

            IF button = 1 THEN
                change = 3
            END IF
        END IF

        IF my >= 433 AND my <= 443 THEN
            setR4 = 55
            setG4 = 255
            setB4 = 0

            IF button = 1 THEN
                change = 4
            END IF
        END IF
    END IF

    LINE (515, 668)-(555, 688), _RGB(255, 255, 255), B

    COLOR _RGB(setR, setG, setB)
    LOCATE 43, 66: PRINT "EXIT"

    ' Time format:

    COLOR _RGB(setR1, setG1, setB1)
    LOCATE 12, 20: PRINT "[*] ";
    COLOR _RGB(255, 255, 255)
    PRINT "Time format settings"

    LOCATE 13, 24: PRINT "Current: "; timeFormat + "h format."

    IF change = 1 THEN
        IF timeFormat = "12" THEN
            timeFormat = "24"
            last_time = 1
        END IF

        IF timeFormat = "24" AND last_time = 0 THEN
            timeFormat = "12"
        END IF

        COLOR _RGB(0, 0, 0)
        LOCATE 15, 24: PRINT "This deletes messages."

        last_time = 0
        change = 0
    END IF

    COLOR _RGB(255, 255, 255)
    hour = MID$(TIME$, 1, 2)
    minute = MID$(TIME$, 4, 2)

    IF timeFormat = "24" THEN
        hour = MID$(TIME$, 1, 2)
        minute = MID$(TIME$, 4, 2)

        LOCATE 15, 24: PRINT hour; ":"; minute;
    END IF

    IF timeFormat = "12" THEN
        hour = MID$(TIME$, 1, 2)
        minute = MID$(TIME$, 4, 2)

        IF VAL(hour) > 12 THEN
            timeInd = "PM"
            hour = LTRIM$(RTRIM$(STR$(VAL(hour) - 12)))
        ELSE
            timeInd = "AM"
        END IF

        LOCATE 15, 24: PRINT hour; ":"; minute; timeInd
    END IF

    ' Autosave pixel size:

    COLOR _RGB(setR2, setG2, setB2)
    LOCATE 18, 20: PRINT "[*] ";
    COLOR _RGB(255, 255, 255)
    PRINT "Autosave pixel size settings"

    LOCATE 19, 24: PRINT "Determines the size of one autosave"
    LOCATE 20, 24: PRINT "drawing pixel when displayed in menu."
    LOCATE 21, 24: PRINT "Current: "; autoSaveBlockSize

    IF change = 2 THEN
        LINE (185, 340)-(275, 360), _RGB(0, 0, 0), BF
        LINE (185, 350)-(275, 350), _RGB(255, 255, 255)

        IF mx >= 185 AND mx <= 275 THEN
            autoSaveBlockSize = (mx - 185) / 18 + 1
            LINE (185 + (18 * (autoSaveBlockSize - 1)), 345)-(185 + (18 * (autoSaveBlockSize - 1)), 355), _RGB(255, 255, 255)
        END IF
    END IF

    ' Frames per second:

    COLOR _RGB(setR3, setG3, setB3)
    LOCATE 24, 20: PRINT "[*] ";
    COLOR _RGB(255, 255, 255)
    PRINT "FPS settings"

    LOCATE 25, 24: PRINT "Current: ";
    IF frames = 0 THEN
        PRINT "not limited    "
    ELSE
        PRINT "limited to"; frames
    END IF

    IF change = 3 THEN
        LINE (185, 410)-(345, 420), _RGB(0, 0, 0), BF
        LINE (185, 415)-(345, 415), _RGB(255, 255, 255)

        IF mx < 185 THEN
            mx = 185
        END IF

        frames = (mx - 185) / 8
        LINE (185 + (frames * 8), 410)-(185 + (frames * 8), 420), _RGB(255, 255, 255)

        frames = (frames + 1) * 30
        IF frames <= 0 OR frames >= 630 THEN
            frames = 0
        END IF

        COLOR _RGB(0, 0, 0)
    END IF

    ' Directory:

    COLOR _RGB(setR4, setG4, setB4)
    LOCATE 28, 20: PRINT "[*] ";
    COLOR _RGB(255, 255, 255)
    PRINT "Directory settings"

    IF new_dir = "" THEN
        new_dir = _CWD$
    END IF
    LOCATE 29, 24: PRINT "Current directory: "; new_dir

    IF change = 4 THEN
        LOCATE 30, 24: INPUT "New directroy: ", new_dir_mid
        new_dir = ""

        CLS

        FOR i = 1 TO LEN(new_dir_mid)
            IF MID$(new_dir_mid, i, 1) = " " THEN
                new_dir = new_dir + "\"
                GOTO skip_dir_set
            END IF

            new_dir = new_dir + MID$(new_dir_mid, i, 1)
            skip_dir_set:
        NEXT i

        change = 0

        IF _DIREXISTS(new_dir) = -1 THEN
            CHDIR new_dir
        ELSE
            new_dir = _CWD$
            CHDIR _CWD$
        END IF

        IF new_dir = "" THEN
            new_dir = _CWD$
            CHDIR _CWD$
        END IF

    END IF

LOOP

END

showDialog:
CLS

DIM messageLine(200) AS STRING
DIM messageLen(200) AS INTEGER
DIM messageY(200) AS INTEGER
DIM messageX(200) AS INTEGER

DIM delayTime AS _FLOAT
delayTime = 1.0

i = 0
keyin = ""

OPEN "info.txt" FOR INPUT AS #1
DO
    i = i + 1
    INPUT #1, messageLine(i)
    messageLen(i) = LEN(messageLine(i))

    IF i > 200 THEN
        GOTO endInput
    END IF
LOOP UNTIL EOF(1)

endInput:
CLOSE #1

FOR j = 1 TO i
    messageY(j) = 40 + j
    messageX(j) = 68 - FIX((messageLen(j) / 2))
NEXT j

DO
    _DELAY delayTime
    LINE (0, 0)-(1080, 720), _RGB(0, 0, 0), BF

    keyin = INKEY$

    IF keyin = "+" THEN
        delayTime = delayTime - 0.5
        IF delayTime < 0.5 THEN
            delayTime = 0.5
        END IF
    END IF

    IF keyin = "-" THEN
        delayTime = delayTime + 0.5
        IF delayTime > 5.0 THEN
            delayTime = 5.0
        END IF
    END IF

    IF keyin = "q" THEN
        GOTO back
    END IF

    FOR j = 1 TO i
        IF messageY(j) < 41 AND messageY(j) > 0 THEN
            LOCATE messageY(j), messageX(j): PRINT messageLine(j)
        END IF
        messageY(j) = messageY(j) - 1

        IF messageY(i) = 0 THEN
            LINE (0, 0)-(1080, 720), _RGB(0, 0, 0), BF
            GOTO back
        END IF
    NEXT j

    IF keyin = "w" THEN
        DO
            keyin = INKEY$
        LOOP UNTIL keyin <> ""
    END IF

LOOP

END

' code from TapTalk QB forum
' https://www.tapatalk.com/groups/qbasic/32-bit-color-bmp-export-save32-t31111.html

SUB Save32 (x1%, y1%, x2%, y2%, image&, Filename$)
    TYPE BMPFormat ' Description Bytes QB64 Function
        ID AS STRING * 2 ' File ID("BM" text or 19778 AS Integer) 2 CVI("BM")
        Size AS LONG ' Total Size of the file 4 LOF
        Blank AS LONG ' Reserved 4
        Offset AS LONG ' Start offset of image pixel data 4 (add one for GET)
        Hsize AS LONG ' Info header size (always 40) 4
        PWidth AS LONG ' Image width 4 _WIDTH(handle&)
        PDepth AS LONG ' Image height (doubled in icons) 4 _HEIGHT(handle&)
        Planes AS INTEGER ' Number of planes (normally 1) 2
        BPP AS INTEGER ' Bits per pixel(palette 1, 4, 8, 24) 2 _PIXELSIZE(handle&)
        Compression AS LONG ' Compression type(normally 0) 4
        ImageBytes AS LONG ' (Width + padder) * Height 4
        Xres AS LONG ' Width in PELS per metre(normally 0) 4
        Yres AS LONG ' Depth in PELS per metre(normally 0) 4
        NumColors AS LONG ' Number of Colors(normally 0) 4 2 ^ BPP
        SigColors AS LONG ' Significant Colors(normally 0) 4
    END TYPE ' Total Header bytes = 54

    DIM BMP AS BMPFormat
    DIM x AS LONG, y AS LONG
    DIM temp AS STRING * 3
    DIM m AS _MEM, n AS _MEM
    DIM o AS _OFFSET
    m = _MEMIMAGE(image&)
    DIM Colors8%(255)

    IF x1% > x2% THEN SWAP x1%, x2%
    IF y1% > y2% THEN SWAP y1%, y2%
    _SOURCE image&
    pixelbytes& = 4
    OffsetBITS& = 54 'no palette in 24/32 bit
    BPP% = 24
    NumColors& = 0 '24/32 bit say zero
    BMP.PWidth = (x2% - x1%) + 1
    BMP.PDepth = (y2% - y1%) + 1

    ImageSize& = BMP.PWidth * BMP.PDepth

    BMP.ID = "BM"
    BMP.Size = ImageSize& * 3 + 54
    BMP.Blank = 0
    BMP.Offset = 54
    BMP.Hsize = 40
    BMP.Planes = 1
    BMP.BPP = 24
    BMP.Compression = 0
    BMP.ImageBytes = ImageSize&
    BMP.Xres = 3780
    BMP.Yres = 3780
    BMP.NumColors = 0
    BMP.SigColors = 0

    Compression& = 0
    WidthPELS& = 3780
    DepthPELS& = 3780
    SigColors& = 0
    f = FREEFILE
    n = _MEMNEW(BMP.Size)
    _MEMPUT n, n.OFFSET, BMP
    o = n.OFFSET + 54

    $CHECKING:OFF
    y = y2% + 1
    w& = _WIDTH(image&)
    DO
        y = y - 1: x = x1% - 1
        DO
            x = x + 1
            _MEMGET m, m.OFFSET + (w& * y + x) * 4, temp
            _MEMPUT n, o, temp
            o = o + 3
        LOOP UNTIL x = x2%
    LOOP UNTIL y = y1%
    $CHECKING:ON
    0 _MEMFREE m
    OPEN Filename$ FOR BINARY AS #f
    t$ = SPACE$(BMP.Size)
    _MEMGET n, n.OFFSET, t$
    PUT #f, , t$
    _MEMFREE n
    CLOSE #f

    SCREEN _NEWIMAGE(1080, 720, 32)
END SUB


