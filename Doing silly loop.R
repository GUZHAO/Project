for (i in 1:1000) {
  for (j in 1:501) {
    if (round(j/i, digits = 3)==0.504) {
      print(paste(i, j))
    }
  }
}
