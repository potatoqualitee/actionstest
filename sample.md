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

.poo {
    font-size: 10px;
    color: gray;
}

.sup {
    font-size: 40px;
    text-align: center;
    font-weight: bold;
    font-family: "Dubai Medium", "Cascadia Mono SemiBold";
}

.outer {
  display: table;
  position: absolute;
  top: 0;
  left: 0;
  height: 95%;
  width: 100%;
}

.middle {
  display: table-cell;
  vertical-align: middle;
}

.inner {
  margin-left: auto;
  margin-right: auto;
  width: 85%;
  height: auto;
}
</style>

<div class="outer">
<div class="middle">
<div class="inner">
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

<h2>Synopsis</h2>
<div>
Adds database(s) to an Availability Group on a SQL Server instance
</div>

<h2>Example</h2>
```
Add-DbaAgDatabase -SqlInstance sql2017a -AvailabilityGroup ag1 -Database db1, db2 -Confirm
```
<br/><div class="poo">dbatools.io</div>
</div>
</div>
</div>