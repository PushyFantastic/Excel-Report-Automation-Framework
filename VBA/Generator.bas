Attribute VB_Name = "Generator"
'#######################################################################################
'################## Created by Joerg Wood (github.com/PushyFantastic) ##################
'#######################################################################################

Sub Import() 'Importer

Dim thisWB As Workbook
Dim autoWS As Worksheet
Dim impWB As Workbook
Dim impWS As Worksheet
Dim inpWS As Worksheet
Dim formWS As Worksheet
Dim copyRange As Range
Dim pasteRange As Range
Dim lRow1 As Long
Dim lRow2 As Long
Set thisWB = ThisWorkbook
Set autoWS = thisWB.Sheets("AUTOMATION")

Application.ScreenUpdating = False
Application.Calculation = xlCalculationManual

For x = 2 To 50

    If Not autoWS.Cells(x, 1).Value = "i" Then GoTo skip
    If Not autoWS.Cells(x, 2).Value = "y" Then GoTo skip

    Set inpWS = thisWB.Sheets(autoWS.Cells(x, 5).Value)
    On Error Resume Next
    inpWS.ShowAllData
    On Error GoTo 0

    Set impWB = Workbooks.Open(Filename:=autoWS.Cells(x, 3).Value, ReadOnly:=True)
    impWB.Activate
    Set impWS = ActiveSheet

    If Not autoWS.Cells(x, 7).Value = 0 Then 'if has headers
        impWS.Rows("1:" & autoWS.Cells(x, 7)).Delete 'delete the headers
    End If

    If Not autoWS.Cells(x, 8).Value = 0 Then 'if has footers
    'find footer range
        lRow1 = LastRow(impWS.Name, "A")
        impWS.Rows(autoWS.Cells(x, 8) - lRow1 + 1 & ":" & lRow1).Delete ' delete the footers
    End If

    If autoWS.Cells(x, 4).Value = "Append" Then                                                                 'if we are appending or overwriting
        Set copyRange = impWS.Range("A1:" & LastColumn(impWS.Name, "1") & LastRow(impWS.Name, "A"))     'appending
        Set pasteRange = inpWS.Range("A" & LastRow(inpWS.Name, "A") + 1 & ":" & LastColumn(impWS.Name, "1") & LastRow(impWS.Name, "A") + LastRow(inpWS.Name, "A") + 1)
        pasteRange = copyRange.Value
    Else
        Set copyRange = impWS.Range("A:" & LastColumn(impWS.Name, "1")) 'overwriting
        Set pasteRange = inpWS.Range("A:" & LastColumn(impWS.Name, "1"))
        pasteRange = copyRange.Value
    End If

    Application.DisplayAlerts = False
    impWB.Close
    Application.DisplayAlerts = True

    thisWB.Activate

    If Not autoWS.Cells(x, 6).Value = "" Then 'if has related formula sheet

        Set formWS = thisWB.Sheets(autoWS.Cells(x, 6).Value)

        On Error Resume Next
        formWS.ShowAllData
        On Error GoTo 0

        lRow1 = LastRow(formWS.Name, "A")
        lRow2 = LastRow(inpWS.Name, "A")

        If autoWS.Cells(x, 4).Value = "Append" Then 'if append
                Set formWS = thisWB.Sheets(autoWS.Cells(x, 6).Value)
                formWS.Range("A" & lRow1 + 1 & ":A" & lRow2) = Format(Now(), "DD/MM/YYYY")
        Else 'if overwrite
                If lRow1 >= 3 Then
                    formWS.Rows("3:" & lRow1).Delete 'delete rows after row3
                End If
                formWS.Range("A2:A" & lRow2) = Format(Now(), "DD/MM/YYYY")
        End If

        Set copyRange = formWS.Range("B2:" & LastColumn(formWS.Name, "1") & "2")
        Set pasteRange = formWS.Range("B3:" & LastColumn(formWS.Name, "1") & lRow2)
        copyRange.Copy pasteRange
    End If

skip:

Next x

Application.ScreenUpdating = True
Application.Calculation = xlCalculationAutomatic
thisWB.RefreshAll

End Sub

Sub Output() 'Exporter

Dim thisWB As Workbook
Dim opWB As Workbook
Dim autoWS As Worksheet
Dim opWS As Worksheet
Dim valS As String
Dim opArr() As String
Dim coll1 As Collection
Dim coll2 As Collection
Dim coll3 As Collection
Dim coll4 As Collection
Dim coll5 As Collection


Set thisWB = ThisWorkbook
Set autoWS = thisWB.Sheets("AUTOMATION")

Call SelectAllFilter

Application.ScreenUpdating = False
Application.Calculation = xlCalculationManual

For x = 2 To 50

    If Not autoWS.Cells(x, 1).Value = "o" Then GoTo skip
    If Not autoWS.Cells(x, 2).Value = "y" Then GoTo skip

    Set coll1 = New Collection
    Set coll2 = New Collection
    Set coll3 = New Collection
    Set coll4 = New Collection
    Set coll5 = New Collection

    For y = 4 To 71 Step 5
    'set colls
        If Not autoWS.Cells(x, y).Value = "" Then
            coll1.Add autoWS.Cells(x, y).Value
            coll2.Add autoWS.Cells(x, y + 1).Value
            coll3.Add autoWS.Cells(x, y + 2).Value
            coll4.Add autoWS.Cells(x, y + 3).Value
            coll5.Add autoWS.Cells(x, y + 4).Value
            If y = 4 Then
                ReDim opArr(0)
                opArr(0) = autoWS.Cells(x, y).Value
            Else
                ReDim Preserve opArr((y + 1) / 5 - 1)
                opArr((y + 1) / 5 - 1) = autoWS.Cells(x, y).Value
            End If
        End If
    Next y

Sheets(opArr).Copy
Set opWB = ActiveWorkbook

If InStr(1, autoWS.Cells(x, 3).Value, ".xlsm") > 0 Then 'if filename contains .xlsm then import vb & assign buttons (=0 means not found)
    ImportVB.AddBas
    ImportVB.AssignButtons
End If

    For Z = 1 To coll1.Count
    opWB.Sheets(coll1(Z)).Activate
        If coll2(Z) = "y" Then
            opWB.Sheets(coll1(Z)).Range("A1:" & LastColumn(coll1(Z), "1") & LastRow(coll1(Z), "A")) = opWB.Sheets(coll1(Z)).Range("A1:" & LastColumn(coll1(Z), "1") & LastRow(coll1(Z), "A")).Value
        Else
            If IsNumeric(coll2(Z)) Then
                opWB.Sheets(coll1(Z)).Columns("1:" & coll2(Z)) = opWB.Sheets(coll1(Z)).Columns("1:" & coll2(Z)).Value
            End If
        End If
        If coll3(Z) = "y" Then
            Selection.AutoFilter
            ActiveSheet.Range("A1:" & LastColumn(ActiveSheet.Name, "1") & LastRow(ActiveSheet.Name, "A")).AutoFilter Field:=coll4(Z), Criteria1:=coll5(Z), Operator:=xlAnd
        End If
        ActiveSheet.Cells(1, 1).Select
        If coll3(Z) = "h" Then
            opWB.Sheets(coll1(Z)).Visible = False
        End If
    Next Z


Dim FName As String
FName = InjectDate(autoWS.Cells(x, 3).Value) 'set filename

          'save & close output file
If InStr(1, FName, ".xlsm") = 0 Then 'if the filename does not contain ".xlsm" (=0 means not found)
    opWB.SaveAs Filename:=FName, FileFormat:=xlOpenXMLWorkbook 'save as .xlsx
Else
    opWB.SaveAs Filename:=FName, FileFormat:=xlOpenXMLWorkbookMacroEnabled 'save as .xlsm
End If

Application.DisplayAlerts = False
opWB.Close
Application.DisplayAlerts = True

skip:

Next x

Application.ScreenUpdating = True
Application.Calculation = xlCalculationAutomatic

Call Reset.Reset

autoWS.Activate
autoWS.Range("DistributionList").Copy

MsgBox ("All done!" & vbNewLine & vbNewLine & "Distribution list has been copied to clipboard.")


End Sub

Sub SelectAllFilter()

Dim ws As Worksheet
Dim b As Shape
Dim i As Integer
Dim box As Object

Set ws = ActiveWorkbook.Sheets("Dashboard")

    On Error GoTo skip
    
    For Each b In ws.Shapes
        If Not InStr(1, b.Name, "Box") = 0 Then
            Set box = b.OLEFormat.Object
            With box
                For i = 1 To .ListCount
                    .Selected(i) = True
                Next i
            End With
        End If
skip:
    Next b

End Sub