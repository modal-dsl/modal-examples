tableextension 50040 "LM Comment Line Ext" extends "Comment Line"
{
	fields
	{
		modify("No.")
		{
			TableRelation = if ("Table Name" = const(Patient)) "LM Patient";
		}
	}
}
