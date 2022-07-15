<style>
.header {
	display: table-cell;
    width: 125px;
    font-weight: bold;
}
h1 {
    font-size: 40px;
    text-align: center;
}

.sup {
    font-size: 40px;
    text-align: center;
    font-weight: bold;
}
</style>

<div style="float:right;margin-top: 24px;">
<img align="right" src=https://github.com/dataplat/dbatools/raw/development/bin/dbatools.png alt="dbatools logo">
</div>

<font class="sup">Add-DbaAgDatabase</font>


<div style="display: table;">
<div style="display: table-row;">
<div class="header">Author</div>
<div style="display: table-cell;">Author Chrissy LeMaire (@cl), netnerds.net , Andreas Jordan (@JordanOrdix), ordix.de</div>
</div>
<div style="display: table-row;">
<div class="header">Availability</div>
<div style="display: table-cell;">Windows, Linux, macOS</div>
</div>
</div>

<div>
Adds database(s) to an Availability Group on a SQL Server instance
</div>

```
Add-DbaAgDatabase -SqlInstance sql2017a -AvailabilityGroup ag1 -Database db1, db2 -Confirm
```

