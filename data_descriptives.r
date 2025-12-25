imm_desc <- textDescriptives(imm_data$pos)
md_desc <- textDescriptives(shuffled_mddata$pos)

print(imm_desc, width = Inf)
print(md_desc, width = Inf)
