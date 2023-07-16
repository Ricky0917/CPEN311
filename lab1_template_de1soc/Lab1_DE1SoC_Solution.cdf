/* Quartus Prime Version 18.1.0 Build 625 09/12/2018 SJ Lite Edition */
JedecChain;
	FileRevision(JESD32A);
	DefaultMfr(6E);

	P ActionCode(Ign)
		Device PartName(5CSEMA5F31) MfrSpec(OpMask(0) FullPath("D:/cpen311/lab1_template_de1soc/Lab1_DE1SoC_Solution.sof"));
	P ActionCode(Cfg)
		Device PartName(5CSEMA5F31) Path("D:/cpen311/lab1_template_de1soc/") File("Lab1_DE1SoC_Solution.sof") MfrSpec(OpMask(1));

ChainEnd;

AlteraBegin;
	ChainType(JTAG);
AlteraEnd;
