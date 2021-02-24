tableextension 50000 "FM Comment Line Ext" extends "Comment Line"
{
	fields
	{
		modify("No.")
		{
			TableRelation = if ("Table Name" = const(Apartment)) "FM Apartment";
		}
	}
}
