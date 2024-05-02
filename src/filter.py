from Bio import SeqIO
file = list(SeqIO.parse('../results/43024/HApro97','fasta'))
filtered_file = open('../results/filtered_HApro97.faa', 'w')
for record in file:
	length = len(record)
	if length>450:
		filtered_file.write('>'+record.id)
		filtered_file.write('\n')
		filtered_file.write(str(record.seq))
		filtered_file.write('\n')


filtered_file.close()

	
