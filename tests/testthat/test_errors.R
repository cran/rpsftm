library(rpsftm)
context("Test for desired errors in rpsftm")

immdef$propX <- with(immdef, 1-xoyrs/progyrs)

test_that("Errors in test argument",{
expect_error( rpsftm(Surv(progyrs, prog)~rand(imm, propX),test=mantelhaen.test,immdef, censor_time = censyrs, 
              low_psi=-1, hi_psi=1), "Test must be one of: survdiff, coxph, survreg")
})

test_that("No Surv object as a response",
          {
            expect_error( 
              rpsftm(progyrs~rand(imm, propX),immdef, censor_time = censyrs),
              "Response must be a survival object")
            
          })

test_that("Wrong type of Survival object",
          {
            expect_error( 
              rpsftm(Surv(progyrs, prog, type="left")~rand(imm, propX),immdef, censor_time = censyrs),
              "rpsftm doesn't support \"left\" survival data")
            
          })



#Check up the error functions  i.e. wrong order of censoring/ events
#rx outside of [0,1]
test_that("Errors in arm >1",{
  expect_error( rpsftm(Surv(progyrs, prog)~rand(imm, propX+1),immdef, censor_time = censyrs, 
                       low_psi=-1, hi_psi=1), "Invalid values for rx")
})

test_that("Errors in arm <1",{
  expect_error( rpsftm(Surv(progyrs, prog)~rand(imm, propX-1),immdef, censor_time = censyrs, 
                       low_psi=-1, hi_psi=1), "Invalid values for rx")
})

test_that("Errors in randomisation out of {0,1}",{
  expect_error( rpsftm(Surv(progyrs, prog)~rand(imm+0.5, propX-1),immdef, censor_time = censyrs, 
                       low_psi=-1, hi_psi=1), "Invalid values for rx")
})


test_that("Censoring before Time warning",{
  expect_warning( rpsftm(Surv(progyrs, prog )~rand(imm, propX),immdef, censor_time=censyrs*0.5,
                       low_psi=-1, hi_psi=1), "You have observed events AFTER censoring")
})

test_that("Variables on left and right terms",
         {
          expect_warning( rpsftm(Surv(progyrs, prog)~rand(imm, 1-xoyrs/progyrs)+progyrs,immdef, censor_time = censyrs, 
                              low_psi=-1, hi_psi=1, test=coxph), "a variable appears on both the left and right sides of the formula")
        
     }
)




test_that("No rand() terms",
          {
            expect_error( rpsftm(Surv(progyrs, prog)~imm,immdef, censor_time = censyrs, 
                                 low_psi=-1, hi_psi=1), "Exactly one rand\\(\\) term allowed")
            
          }
)

test_that("Too many rand() terms",
          {
            expect_error( rpsftm(Surv(progyrs, prog)~def*rand(imm, 1-xoyrs/progyrs),immdef, censor_time = censyrs, 
                                 low_psi=-1, hi_psi=1), "Exactly one rand\\(\\) term allowed")
            
          }
)

test_that("rand() interaction",
          {
            expect_error( rpsftm(Surv(progyrs, prog)~def/rand(imm, 1-xoyrs/progyrs),immdef, censor_time = censyrs, 
                                 low_psi=-1, hi_psi=1), "rand\\(\\) term must not be in any interactions")
            
          }
)



test_that("More than 2 arms",
          {
            myarm <- factor(rep(1:4,250))
            
            expect_error( rpsftm(Surv(progyrs, prog)~rand(myarm, 1-xoyrs/progyrs),immdef, censor_time = censyrs, 
                                 low_psi=-1, hi_psi=1), "arm must have exactly 2 observed values")
          }
)

test_that("less than 2 arms",
          {
            
            
            expect_error( rpsftm(Surv(progyrs, prog)~rand(1, 1-xoyrs/progyrs),immdef, censor_time = censyrs, 
                                 low_psi=-1, hi_psi=1), "arm must have exactly 2 observed values")
          }
)



# missing data handling
#to be implimented

test_that("na actions",
          {
          index <- sample(dim(immdef)[1],20)
          myarm <- immdef$imm
          myarm[index] <- NA
          
          fit <- rpsftm(Surv(progyrs, prog)~rand(imm, 1-xoyrs/progyrs),immdef, censor_time = censyrs, na.action=na.fail,
                        low_psi=-1, hi_psi=1)
          expect_is(fit$psi, class="numeric")
          
          
          fit <- rpsftm(Surv(progyrs, prog)~rand(myarm, 1-xoyrs/progyrs),immdef, censor_time = censyrs, na.action=na.omit,
                 low_psi=-1, hi_psi=1)
          expect_is(fit$psi, class="numeric")
          expect_is(fit$na.action, class="omit")
          
          expect_error(rpsftm(Surv(progyrs, prog)~rand(myarm, 1-xoyrs/progyrs),immdef, censor_time = censyrs, na.action=na.fail,
                        low_psi=-1, hi_psi=1),
                       "missing values in object")
          }
          
          )

test_that("error for poor initial starting values",{
    expect_warning( rpsftm(Surv(progyrs, prog)~rand(imm,1-xoyrs/progyrs),immdef, censor_time = censyrs,
               low_psi=-1, hi_psi=-0.9),
               "The starting interval"
    )
})

test_that("warning for non-convergencevalues",{
  expect_error( fit <- rpsftm(Surv(progyrs, prog)~rand(imm,1-xoyrs/progyrs)+entry,immdef, censor_time = censyrs)
                  )
#  expect_equal(is.na(fit$psi),TRUE)
})


test_that("eval_z incorrect input - too small a number",
          {
            expect_error( rpsftm(Surv(progyrs, prog)~rand(imm,1-xoyrs/progyrs),
                          data=immdef, censor_time = censyrs, n_eval_z=1),
                          "invalid value of n_eval_z"             
            )
            
          }
)


test_that("eval_z incorrect input - vector input",
          {
            expect_error( rpsftm(Surv(progyrs, prog)~rand(imm,1-xoyrs/progyrs),
                                 data=immdef, censor_time = censyrs, n_eval_z=2:10),
                          "invalid value of n_eval_z"             
            )
            
          }
)



test_that("eval_z incorrect input - non-numeric input",
          {
            expect_error( rpsftm(Surv(progyrs, prog)~rand(imm,1-xoyrs/progyrs),
                                 data=immdef, censor_time = censyrs, n_eval_z="hello"),
                          "invalid value of n_eval_z"             
            )
            
          }
)