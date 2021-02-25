codeunit 50043 "LM Patient Jnl.-Post Line"
{
    Permissions = TableData "LM Patient Entry" = imd,
                  TableData "LM Patient Register" = imd;
    TableNo = "LM Patient Journal Line";

    trigger OnRun()
    begin
        RunWithCheck(Rec);
    end;

    var
        NextEntryNo: Integer;
        PatJnlLine: Record "LM Patient Journal Line";
        atientJnlCheckLine: Codeunit "LM Patient Jnl.-Check Line";
        PatEntry: Record "LM Patient Entry";
        PatientReg: Record "LM Patient Register";
        Pat: Record "LM Patient";

    procedure RunWithCheck(var PatJnlLine2: Record "LM Patient Journal Line")
    begin
        PatJnlLine.Copy(PatJnlLine2);
        Code;
        PatJnlLine2 := PatJnlLine;
    end;

    local procedure "Code"()
    var
        IsHandled: Boolean;
    begin
        OnBeforePostJnlLine(PatJnlLine);

        if PatJnlLine.EmptyLine() then
            exit;

        atientJnlCheckLine.RunCheck(PatJnlLine);

        if NextEntryNo = 0 then begin
            PatEntry.LockTable();
            NextEntryNo := PatEntry.GetLastEntryNo() + 1;
        end;

        if PatJnlLine."Document Date" = 0D then
            PatJnlLine."Document Date" := PatJnlLine."Posting Date";

        if PatientReg."No." = 0 then begin
            PatientReg.LockTable();
            if (not PatientReg.FindLast()) or (PatientReg."To Entry No." <> 0) then begin
                PatientReg.Init();
                PatientReg."No." := PatientReg."No." + 1;
                PatientReg."From Entry No." := NextEntryNo;
                PatientReg."To Entry No." := NextEntryNo;
                PatientReg."Creation Date" := Today();
                PatientReg."Creation Time" := Time();
                PatientReg."Source Code" := PatJnlLine."Source Code";
                PatientReg."Journal Batch Name" := PatJnlLine."Journal Batch Name";
                PatientReg."User ID" := UserId();
                PatientReg.Insert();
            end;
        end;
        PatientReg."To Entry No." := NextEntryNo;
        PatientReg.Modify();

        Pat.Get(PatJnlLine."Patient No.");

        IsHandled := false;
        OnBeforeCheckPatBlocked(Pat, IsHandled);
        if not IsHandled then
            Pat.TestField(Blocked, false);

        PatEntry.Init();
        PatEntry.CopyFromPatJnlLine(PatJnlLine);

        PatEntry."User ID" := UserId();
        PatEntry."Entry No." := NextEntryNo;

        OnBeforeLedgerEntryInsert(PatEntry, PatJnlLine);

        PatEntry.Insert(true);

        NextEntryNo := NextEntryNo + 1;

        OnAfterPostJnlLine(PatJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostJnlLine(var PatJnlLine: Record "LM Patient Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPatBlocked(Pat: Record "LM Patient"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeLedgerEntryInsert(var PatEntry: Record "LM Patient Entry"; PatJnlLine: Record "LM Patient Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostJnlLine(var PatJnlLine: Record "LM Patient Journal Line")
    begin
    end;

}
