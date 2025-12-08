(* Define your association here *)
f[x_] := x * (3x - 1) / 2;
values = f[Range[200] - 100];
assoc = <|"data" -> Union[values]|>;

(* Path where you want to save it *)
outfile = FileNameJoin[{Directory[], "output.wl"}];

(* Export as JSON, recommended for readability & interoperability *)
Export[outfile, assoc, "WL"];

(* Optional: print confirmation *)
Print["Saved association to: ", outfile];

Quit[];

