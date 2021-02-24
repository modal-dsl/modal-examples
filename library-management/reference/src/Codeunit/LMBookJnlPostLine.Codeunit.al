codeunit 50023 "LM Book Jnl.-Post Line"
{
    Permissions = TableData "LM Loan Entry" = imd,
                  TableData "LM Book Register" = imd;
    TableNo = "LM Book Journal Line";

    trigger OnRun()
    begin
        RunWithCheck(Rec);
    end;

    var
        NextEntryNo: Integer;
        BookJnlLine: Record "LM Book Journal Line";
        ookJnlCheckLine: Codeunit "LM Book Jnl.-Check Line";
        LoanEntry: Record "LM Loan Entry";
        BookReg: Record "LM Book Register";
        Book: Record "LM Book";

    procedure RunWithCheck(var BookJnlLine2: Record "LM Book Journal Line")
    begin
        BookJnlLine.Copy(BookJnlLine2);
        Code;
        BookJnlLine2 := BookJnlLine;
    end;

    local procedure "Code"()
    var
        IsHandled: Boolean;
    begin
        OnBeforePostJnlLine(BookJnlLine);

        if BookJnlLine.EmptyLine() then
            exit;

        ookJnlCheckLine.RunCheck(BookJnlLine);

        if NextEntryNo = 0 then begin
            LoanEntry.LockTable();
            NextEntryNo := LoanEntry.GetLastEntryNo() + 1;
        end;

        if BookJnlLine."Document Date" = 0D then
            BookJnlLine."Document Date" := BookJnlLine."Posting Date";

        if BookReg."No." = 0 then begin
            BookReg.LockTable();
            if (not BookReg.FindLast()) or (BookReg."To Entry No." <> 0) then begin
                BookReg.Init();
                BookReg."No." := BookReg."No." + 1;
                BookReg."From Entry No." := NextEntryNo;
                BookReg."To Entry No." := NextEntryNo;
                BookReg."Creation Date" := Today();
                BookReg."Creation Time" := Time();
                BookReg."Source Code" := BookJnlLine."Source Code";
                BookReg."Journal Batch Name" := BookJnlLine."Journal Batch Name";
                BookReg."User ID" := UserId();
                BookReg.Insert();
            end;
        end;
        BookReg."To Entry No." := NextEntryNo;
        BookReg.Modify();

        Book.Get(BookJnlLine."Book No.");

        IsHandled := false;
        OnBeforeCheckBookBlocked(Book, IsHandled);
        if not IsHandled then
            Book.TestField(Blocked, false);

        LoanEntry.Init();
        LoanEntry.CopyFromBookJnlLine(BookJnlLine);

        LoanEntry."User ID" := UserId();
        LoanEntry."Entry No." := NextEntryNo;

        OnBeforeLedgerEntryInsert(LoanEntry, BookJnlLine);

        LoanEntry.Insert(true);

        NextEntryNo := NextEntryNo + 1;

        OnAfterPostJnlLine(BookJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostJnlLine(var BookJnlLine: Record "LM Book Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBookBlocked(Book: Record "LM Book"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLedgerEntryInsert(var LoanEntry: Record "LM Loan Entry"; BookJnlLine: Record "LM Book Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostJnlLine(var BookJnlLine: Record "LM Book Journal Line")
    begin
    end;

}
