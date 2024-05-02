from Bio import SeqIO
file = list(SeqIO.parse('gisaid_H5N1_HA.faa','fasta'))
filtered_file = open('filtered_gisaid_H5N1_HA.faa', 'w')
for record in file:
	length = len(record)
	if length>450:
		filtered_file.write('>'+record.id)
		filtered_file.write('\n')
		filtered_file.write(str(record.seq))
		filtered_file.write('\n')


filtered_file.close()

	
