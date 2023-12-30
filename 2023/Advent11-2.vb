' Advent of Code 2023 - Day 11: Cosmic Expansion, part 2
' Mic, 2023

Imports System.Text

Module Module1

    Class Galaxy
        Public x As Integer, y As Integer
        Public Sub New(x As Integer, y As Integer)
            Me.x = x
            Me.y = y
        End Sub
    End Class

    Class Space
        Private image As ArrayList

        Public Sub New(image As ArrayList)
            Me.image = image
        End Sub

        Public Sub Expand()
            Dim columns = Len(DirectCast(image(0), String))
            Dim rows = image.Count
            Dim isEmptyColumn(columns - 1) As Boolean
            For i As Integer = 0 To columns - 1
                Dim isEmpty = True
                For j As Integer = 0 To rows - 1
                    If image(j)(i) <> "."c Then
                        isEmpty = False
                        Exit For
                    End If
                Next
                isEmptyColumn(i) = isEmpty
            Next
            Dim expanded As New ArrayList
            For i As Integer = 0 To image.Count - 1
                Dim expandedRow = ExpandRow(i, isEmptyColumn)
                expanded.Add(expandedRow)
                If Not (DirectCast(image(i), String).Contains("#"c)) Then
                    expanded.Add(StrDup(Len(expandedRow), "e"c))
                End If
            Next
            Me.image = expanded
        End Sub

        Public Function FindGalaxies() As ArrayList
            Dim galaxies As New ArrayList
            For i As Integer = 0 To image.Count - 1
                For j As Integer = 0 To Len(image(0)) - 1
                    If image(i)(j) = "#"c Then
                        galaxies.Add(New Galaxy(j, i))
                    End If
                Next
            Next
            Return galaxies
        End Function

        Public Function DistanceBetween(first As Galaxy, second As Galaxy) As UInt64
            Dim x = first.x, y = first.y
            Dim x2 = second.x, y2 = second.y
            Dim distance As UInt64 = Math.Abs(y2 - y) + Math.Abs(x2 - x)
            Dim dy = y2 - y
            If dy <> 0 Then dy = dy \ Math.Abs(dy)
            While y <> y2
                If image(y)(x) = "e"c Then
                    distance += 1000000 - 2
                End If
                y += dy
            End While
            Dim dx = x2 - x
            If dx <> 0 Then dx = dx \ Math.Abs(dx)
            Dim row = image(y)
            While x <> x2
                If row(x) = "e"c Then
                    distance += 1000000 - 2
                End If
                x += dx
            End While
            Return distance
        End Function

        Private Function ExpandRow(index As Integer, isEmptyColumn As Boolean()) As String
            Dim row = DirectCast(image(index), String)
            Dim expanded As New StringBuilder(row)
            Dim duped = 0
            For i As Integer = 0 To Len(row) - 1
                If isEmptyColumn(i) Then
                    expanded.Insert(i + 1 + duped, "e"c)
                    duped += 1
                End If
            Next
            Return expanded.ToString
        End Function
    End Class

    Sub Main(args As String())
        If args.Length = 0 Then
            Console.WriteLine("Error: No input file specified")
            Exit Sub
        End If

        Dim lines As New ArrayList
        FileOpen(1, args(0), OpenMode.Input)
        Do While Not EOF(1)
            lines.Add(LineInput(1))
        Loop
        FileClose(1)

        Dim space As New Space(lines)
        space.Expand()
        Dim galaxies = space.FindGalaxies
        Console.WriteLine($"There are {galaxies.Count} galaxies")

        Dim sumOfDistances As UInt64 = 0
        For i As Integer = 0 To galaxies.Count - 1
            For j As Integer = i + 1 To galaxies.Count - 1
                sumOfDistances = sumOfDistances + space.DistanceBetween(galaxies(i), galaxies(j))
            Next
        Next

        Console.WriteLine($"The sum of distances is {sumOfDistances}")
    End Sub

End Module
