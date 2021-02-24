codeunit 50005 "FM Navigate Event Sub."
{
	[EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', true, false)]
	local procedure NavigateOnAfterNavigateFindRecords(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
	var
		PstdWrkOrdHeader: Record "FM Posted Work Order Header";
		Navigate: Page Navigate;
	begin
		If PstdWrkOrdHeader.ReadPermission then begin
			PstdWrkOrdHeader.SetFilter("No.", DocNoFilter);
			PstdWrkOrdHeader.SetFilter("Posting Date", PostingDateFilter);
			Navigate.InsertIntoDocEntry(DocumentEntry, Database::"FM Posted Work Order Header", 0, 'Posted Work Order', PstdWrkOrdHeader.Count);
		end;
	end;
	
	[EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', true, false)]
	local procedure NavigateOnAfterNavigateShowRecords(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean; var TempDocumentEntry: Record "Document Entry" temporary; SalesInvoiceHeader: Record "Sales Invoice Header"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; PurchInvHeader: Record "Purch. Inv. Header"; PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; ServiceInvoiceHeader: Record "Service Invoice Header"; ServiceCrMemoHeader: Record "Service Cr.Memo Header")
	var
		PstdWrkOrdHeader: Record "FM Posted Work Order Header";
	begin
		if TableID <> Database::"FM Posted Work Order Header" then
			exit;
		
		PstdWrkOrdHeader.SetFilter("No.", DocNoFilter);
		PstdWrkOrdHeader.SetFilter("Posting Date", PostingDateFilter);
		
		If (TempDocumentEntry."No. of Records" = 1) then
			PAGE.Run(PAGE::"FM Posted Work Order", PstdWrkOrdHeader)
		else
			PAGE.Run(0, PstdWrkOrdHeader);
	end;
}
