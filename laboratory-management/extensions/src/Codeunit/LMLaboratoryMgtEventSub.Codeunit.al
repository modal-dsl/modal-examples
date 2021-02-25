codeunit 50056 "LM Laboratory Mgt. Event Sub."
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Patient-Post", 'OnBeforePostedLineInsert', '', true, false)]
    local procedure PatientPostOnBeforePostedLineInsert(var PstdBldTestLine: Record "LM Posted Blood Test Line"; PstdBldTestHeader: Record "LM Posted Blood Test Header"; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary; BldTestHeader: Record "LM Bld. Test Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    var
        PatientJnlLine: Record "LM Patient Journal Line";
        PatientJnlPostLine: Codeunit "LM Patient Jnl.-Post Line";
    begin
        PatientJnlLine.Init();
        PatientJnlLine."Patient No." := BldTestHeader."Patient No.";
        PatientJnlLine."Posting Date" := BldTestHeader."Posting Date";
        PatientJnlLine."Document Date" := BldTestHeader."Document Date";
        PatientJnlLine."Document No." := PstdBldTestHeader."No.";
        PatientJnlLine."Blood Test No." := BldTestHeader."No.";
        PatientJnlLine."Source No." := BldTestHeader."Patient No.";
        PatientJnlLine."Source Code" := SrcCode;
        PatientJnlLine."Reason Code" := BldTestHeader."Reason Code";
        PatientJnlLine."Posting No. Series" := BldTestHeader."Posting No. Series";
        PatientJnlLine.Description := TempBldTestLineGlobal.Description;
        PatientJnlLine."Measurement" := TempBldTestLineGlobal."Measurement";
        PatientJnlLine."Result" := TempBldTestLineGlobal."Result";

        PatientJnlPostLine.RunWithCheck(PatientJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Patient-Post", 'OnCheckNothingToPost', '', true, false)]
    local procedure PatientPostOnCheckNothingToPost(var BldTestHeader: Record "LM Bld. Test Header"; var TempBldTestLineGlobal: Record "LM Bld. Test Line" temporary)
    var
        NothingToPostErr: Label 'There is nothing to post.';
    begin
        if TempBldTestLineGlobal.IsEmpty() then
            Error(NothingToPostErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Patient-Post", 'OnAfterCheckMandatoryFields', '', true, false)]
    local procedure PatientPostOnAfterCheckMandatoryFields(var BldTestHeader: Record "LM Bld. Test Header"; CommitIsSuppressed: Boolean)
    begin
        BldTestHeader.TestField(Status, BldTestHeader.Status::Finished);
        BldTestHeader.TestField("Patient No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Patient-Post", 'OnTestLine', '', true, false)]
    local procedure PatientPostOnTestLine(var BldTestHeader: Record "LM Bld. Test Header"; var BldTestLine: Record "LM Bld. Test Line"; CommitIsSuppressed: Boolean)
    begin
        BldTestLine.TestField(Description);
        BldTestLine.TestField(Measurement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Patient Jnl.-Check Line", 'OnAfterRunCheck', '', true, false)]
    local procedure PatientJnlCheckLineOnAfterRunCheck(var PatJnlLine: Record "LM Patient Journal Line")
    begin
        PatJnlLine.TestField("Document No.");
        PatJnlLine.TestField("Blood Test No.");
        PatJnlLine.TestField("Patient No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LM Patient Jnl.-Post Line", 'OnBeforePostJnlLine', '', true, false)]
    local procedure PatientJnlPostLineOnBeforePostJnlLine(var PatJnlLine: Record "LM Patient Journal Line")
    var
        Patient: Record "LM Patient";
    begin
        PatJnlLine.TestField("Patient No.");
        Patient.Get(PatJnlLine."Patient No.");
        Patient.TestField(Blocked, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LM Patient Entry", 'OnAfterCopyPatEntryFromPatJnlLine', '', true, false)]
    local procedure PatientEntryOnAfterCopyPatEntryFromPatJnlLine(var PatEntry: Record "LM Patient Entry"; var PatJnlLine: Record "LM Patient Journal Line")
    begin
        PatEntry.Measurement := PatJnlLine.Measurement;
        PatEntry.Result := PatJnlLine.Result;
        PatEntry."Blood Test No." := PatJnlLine."Blood Test No.";
    end;

}
