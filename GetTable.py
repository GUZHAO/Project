from pprint import pprint


def randw(writefile, readfile):
    with open(writefile, 'a') as tb:
        with open(readfile, 'rt') as in_file:
            for line in in_file:
                if "JOIN" in line.upper():
                    print(line.strip())
                    tb.write(line.strip() + '\n')
                if "JOIN" in line.upper():
                    jcont = next(in_file)
                    print(jcont)
                    tb.write(jcont.strip() + '\n')
                if "FROM" in line.upper():
                    print(line.strip())
                    tb.write(line.strip() + '\n')
                if "FROM" in line.upper():
                    fcont = next(in_file)
                    print(fcont.strip())
                    tb.write(fcont.strip() + '\n')


#POPC ACP
randw('//cifs2/coba$/Ad-Hoc Data Requests/POPC Advanced Care Planning QI Project/POPC_ACP.txt',
      '//cifs2/coba$/Ad-Hoc Data Requests/POPC Advanced Care Planning QI Project/AdvancedCarePlanCodeDFCI03192018.txt')

# # popc
# randw('//cifs2/homedir$/Office/Projects/Report Inventory/result/POPC.txt',
#       '//cifs2/homedir$/Office/Projects/Report Inventory/POPC_Oracle.txt')
# # rvu
# randw('//cifs2/homedir$/Office/Projects/Report Inventory/result/RVUMedOnc.txt',
#       '//cifs2/homedir$/Office/Projects/Report Inventory/RVU Adult MedOncFinal.txt')
# # new pt 5 days
# randw('//cifs2/homedir$/Office/Projects/Report Inventory/result/NP5D.txt',
#       '//cifs2/homedir$/Office/Projects/Report Inventory/NewPt5Days.txt')
# # new pt 5 days 2
# randw('//cifs2/homedir$/Office/Projects/Report Inventory/result/NP5D2.txt',
#       '//cifs2/homedir$/Office/Projects/Report Inventory/NewPt5Days2.txt')
# # new pt next day
# randw('//cifs2/homedir$/Office/Projects/Report Inventory/result/NPND.txt',
#       '//cifs2/homedir$/Office/Projects/Report Inventory/NewPtNextDay.txt')
# # new pt next day 2
# randw('//cifs2/homedir$/Office/Projects/Report Inventory/result/NPND2.txt',
#       '//cifs2/homedir$/Office/Projects/Report Inventory/NewPtNextDay2.txt')
