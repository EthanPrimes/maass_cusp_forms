x=NumberFieldClassNumber[Sqrt[10^11+1]];
SendMail["To"->"ethanpalenske@gmail.com","Subject"->"Test from Mathematica","Body"->ToString[StringForm["Hello, Ethan! Your computations finished running. The class number of 10^11 + 1 is ``.", x]],"From"->"ethanpalenske@gmail.com","Server"->"smtp.gmail.com","PortNumber"->587,"EncryptionProtocol"->"StartTLS","UserName"->"ethanpalenske@gmail.com","Password"->"stil rjcg pzza vemh"];
Quit[]
