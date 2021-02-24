codeunit 50131 "SEM Seminar Extensions Mgt."
{

    SingleInstance = true;

    var
        NotLessErr: Label 'must not be less than %1';
        NotGreaterErr: Label 'must not be greater than %1';
        LastResEntryNo: Integer;

    procedure CheckMinValue(FldRef: FieldRef; ActualValue: Decimal; MinValue: Decimal)
    begin
        if (ActualValue < MinValue) then
            FldRef.FieldError(StrSubstNo(NotLessErr, MinValue));
    end;

    procedure CheckLessThan(CurrentFldRef: FieldRef; CurrentValue: Decimal; OtherFldRef: FieldRef; OtherValue: Decimal)
    begin
        if (OtherValue <> 0) and (CurrentValue > OtherValue) then
            CurrentFldRef.FieldError(StrSubstNo(NotGreaterErr, OtherFldRef.Caption));
    end;

    procedure CheckGreaterThan(CurrentFldRef: FieldRef; CurrentValue: Decimal; OtherFldRef: FieldRef; OtherValue: Decimal)
    begin
        if (OtherValue <> 0) and (CurrentValue < OtherValue) then
            CurrentFldRef.FieldError(StrSubstNo(NotLessErr, OtherFldRef.Caption));
    end;

    procedure SetLastResEntryNo(EntryNo: Integer)
    begin
        LastResEntryNo := EntryNo;
    end;

    procedure GetLastResEntryNo(): Integer
    begin
        exit(LastResEntryNo);
    end;

}
