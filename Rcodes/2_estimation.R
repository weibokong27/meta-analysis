rm(list = ls())

# --------- library and functions -------------
source("Rcodes/0_library.R")
source("Rcodes/0a_helper.R")
source("Rcodes/0c_simulation.R")


gamma.true = c(0,-1)
beta.true = c(-7, 0.5)
eta.true = c(0.2,-1)

# --------- load data ------------------------
cohort.dat = simCohort(n = 1000, gamma.true = gamma.true, beta.true = beta.true, eta.true = eta.true)
casecrt.dat = simCasecrt(n = 200, pr = 1/3, gamma.true = gamma.true, beta.true = beta.true, eta.true = eta.true)

test1 = brm(y = cohort.dat$y, 
            x = cohort.dat$z, 
            va = cbind(cohort.dat$v1, cohort.dat$v2),
            vb = cbind(cohort.dat$v1, cohort.dat$v2),
            param = "RR",
            alpha.start = c(0,0),
            beta.start = c(0,0))

# -------- estimation, case control only ----------
# propensity score model
ps.model = glm(z ~ v2, data = cohort.dat, family = binomial(link='logit'))
ps = predict(ps.model, type = "response", newdata = casecrt.dat)
ps.mat = cbind(1-ps, ps)

test2 = max.likelihood.casecrt(y = casecrt.dat$y, 
                               z = casecrt.dat$z, 
                               ps.mat = ps.mat,
                               va = cbind(casecrt.dat$v1, casecrt.dat$v2),
                               vb = cbind(casecrt.dat$v1, casecrt.dat$v2),
                               alpha.start = test1$point.est[c(1,2)],
                               beta.start = test1$point.est[c(3,4)])

# -------- estimation, both ----------
test.all = max.likelihood.all(case.control = list(y = casecrt.dat$y, 
                                                  z = casecrt.dat$z, 
                                                  va = cbind(casecrt.dat$v1, casecrt.dat$v2),
                                                  vb = cbind(casecrt.dat$v1, casecrt.dat$v2)),
                              cohort = list(y = cohort.dat$y, 
                                            z = cohort.dat$z, 
                                            va = cbind(cohort.dat$v1, cohort.dat$v2),
                                            vb = cbind(cohort.dat$v1, cohort.dat$v2)),
                              alpha.start = test1$point.est[c(1,2)],
                              beta.start = test1$point.est[c(3,4)],
                              eta.start = ps.model$coefficients)
                              

test1$coefficients
test2$coefficients
test.all$coefficients


