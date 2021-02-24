codeunit 50016 "FM Facility Mgt. Event Sub."
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FM Apartment-Post", 'OnBeforePostedLineInsert', '', true, false)]
    local procedure ApartmentPostOnBeforePostedLineInsert(var PstdWrkOrdLine: Record "FM Posted Work Order Line"; PstdWrkOrdHeader: Record "FM Posted Work Order Header"; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary; WrkOrdHeader: Record "FM Wrk. Ord. Header"; SrcCode: Code[10]; CommitIsSuppressed: Boolean)
    var
        AptJnlLine: Record "FM Apartment Journal Line";
        AptJnlPostLine: Codeunit "FM Apartment Jnl.-Post Line";
    begin
        AptJnlLine.Init();
        AptJnlLine."Apartment No." := WrkOrdHeader."Apartment No.";
        AptJnlLine."Posting Date" := WrkOrdHeader."Posting Date";
        AptJnlLine."Document Date" := WrkOrdHeader."Document Date";
        AptJnlLine."Document No." := PstdWrkOrdHeader."No.";
        AptJnlLine."Work Order No." := WrkOrdHeader."No.";
        AptJnlLine."Source No." := WrkOrdHeader."Apartment No.";
        AptJnlLine."Source Code" := SrcCode;
        AptJnlLine."Reason Code" := WrkOrdHeader."Reason Code";
        AptJnlLine."Posting No. Series" := WrkOrdHeader."Posting No. Series";
        AptJnlLine."Mt. Wk. Code" := WrkOrdHeader."Mt. Wk. Code";
        AptJnlLine."Wrk. Ord. Requested By" := WrkOrdHeader."Requested By";
        AptJnlLine."Wrk. Ord. Cost Type" := TempWrkOrdLineGlobal."Cost Type";
        AptJnlLine."Wrk. Ord. Quantity" := TempWrkOrdLineGlobal.Quantity;
        AptJnlLine."Wrk. Ord. Amount" := TempWrkOrdLineGlobal.Amount;
        AptJnlLine.Description := TempWrkOrdLineGlobal.Description;

        AptJnlPostLine.RunWithCheck(AptJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FM Apartment-Post", 'OnCheckNothingToPost', '', true, false)]
    local procedure ApartmentPostOnCheckNothingToPost(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var TempWrkOrdLineGlobal: Record "FM Wrk. Ord. Line" temporary)
    var
        NothingToPostErr: Label 'There is nothing to post.';
    begin
        TempWrkOrdLineGlobal.SetFilter(Quantity, '>%1', 0);
        if TempWrkOrdLineGlobal.IsEmpty() then
            Error(NothingToPostErr);

        TempWrkOrdLineGlobal.SetRange(Quantity);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FM Apartment-Post", 'OnAfterCheckMandatoryFields', '', true, false)]
    local procedure ApartmentPostOnAfterCheckMandatoryFields(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; CommitIsSuppressed: Boolean)
    begin
        WrkOrdHeader.TestField(Status, WrkOrdHeader.Status::Finished);
        WrkOrdHeader.TestField("Apartment No.");
        WrkOrdHeader.TestField("Requested By");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FM Apartment-Post", 'OnTestLine', '', true, false)]
    local procedure ApartmentPostOnTestLine(var WrkOrdHeader: Record "FM Wrk. Ord. Header"; var WrkOrdLine: Record "FM Wrk. Ord. Line"; CommitIsSuppressed: Boolean)
    begin
        WrkOrdLine.TestField(Description);
        WrkOrdLine.TestField(Quantity);
        WrkOrdLine.TestField(Amount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FM Apartment Jnl.-Check Line", 'OnAfterRunCheck', '', true, false)]
    local procedure ApartmentJnlCheckLineOnAfterRunCheck(var AptJnlLine: Record "FM Apartment Journal Line")
    begin
        AptJnlLine.TestField("Document No.");
        AptJnlLine.TestField("Work Order No.");
        AptJnlLine.TestField("Apartment No.");
        AptJnlLine.TestField("Mt. Wk. Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FM Apartment Jnl.-Post Line", 'OnBeforePostJnlLine', '', true, false)]
    local procedure ApartmentJnlPostLineOnBeforePostJnlLine(var AptJnlLine: Record "FM Apartment Journal Line")
    var
        Apt: Record "FM Apartment";
        MtWorker: Record "FM Maintenance Worker";
    begin
        AptJnlLine.TestField("Apartment No.");
        Apt.Get(AptJnlLine."Apartment No.");
        Apt.TestField(Blocked, false);

        AptJnlLine.TestField("Mt. Wk. Code");
        MtWorker.Get(AptJnlLine."Mt. Wk. Code");
        MtWorker.TestField(Blocked, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"FM Apartment Journal Line", 'OnBeforeEmptyLine', '', true, false)]
    local procedure AptJnlLineOnBeforeEmptyLine(AptJnlLine: Record "FM Apartment Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := true;
        Result := ((AptJnlLine."Apartment No." = '') and ((AptJnlLine."Wrk. Ord. Amount" = 0) or (AptJnlLine."Wrk. Ord. Quantity" = 0)));
    end;

    [EventSubscriber(ObjectType::Table, Database::"FM Work Order Entry", 'OnAfterCopyWrkOrdEntryFromAptJnlLine', '', true, false)]
    local procedure AptLedgerEntryOnAfterCopyWrkOrdEntryFromAptJnlLine(var WrkOrdEntry: Record "FM Work Order Entry"; var AptJnlLine: Record "FM Apartment Journal Line")
    begin
        WrkOrdEntry."Mt. Wk. Code" := AptJnlLine."Mt. Wk. Code";
        WrkOrdEntry."Wrk. Ord. Requested By" := AptJnlLine."Wrk. Ord. Requested By";
        WrkOrdEntry."Wrk. Ord. Cost Type" := AptJnlLine."Wrk. Ord. Cost Type";
        WrkOrdEntry."Wrk. Ord. Quantity" := AptJnlLine."Wrk. Ord. Quantity";
        WrkOrdEntry."Wrk. Ord. Amount" := AptJnlLine."Wrk. Ord. Amount";
        WrkOrdEntry."Work Order No." := AptJnlLine."Work Order No.";
    end;

}
