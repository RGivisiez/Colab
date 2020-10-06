Module Variaveis

  Integer*4, Parameter :: L = 40;
  Integer*4, Parameter :: nsitios = L;
  Integer*4, Parameter :: mc_steps = int(1e6);
  Integer*4, Parameter :: term_steps = 1000 * L * L;
  Real*8, Parameter :: Temp_ini = 3.0d0;
  Real*8, parameter :: dt = 0.1d0;
  Integer*4, Parameter :: temp_steps = 1

  Real*8, Allocatable, Dimension (:) :: S
  Real*8, Allocatable, Dimension (:) :: rx
  Real*8, Allocatable, Dimension (:) :: ry
  Real*8, Allocatable, Dimension (:) :: E
  Real*8, Allocatable, Dimension (:) :: M
  Integer*4, Allocatable, Dimension (:) :: viz

  Real*8 ener
  Real*8 beta
  Real*8 temp

End Module Variaveis


Program Main

  Use Variaveis
  Implicit None

  Allocate(S(nsitios), rx(nsitios), ry(nsitios), viz(nsitios * 2))
  Allocate(E(mc_steps), M(mc_steps))

  ! Call init_random_seed()

  Call conf_ini

  Call neighbors

  Call energia_ini

  Call temperatura_steps

End Program Main

Subroutine conf_ini

  Use Variaveis
  Implicit None
  
  Integer*4 i
  Real*8 ran
  
  Do i = 1, nsitios
  
    Call random_number(ran)
    
    S(i) = (-1.0d0)**nint(ran)

  end do
  
End Subroutine conf_ini

Subroutine neighbors

  Use Variaveis
  Implicit None

  Integer*4 i, cont

  cont = 0; 

  Do i = 1, L

    cont = cont + 1;
    
    rx(cont) = dble(i);

    viz(2 * (cont - 1) + 1) = cont + 1;
    viz(2 * (cont - 1) + 2) = cont - 1;

    if( i == L ) viz(2 * (cont - 1) + 1) = cont + 1 - L;
    if( i == 1 ) viz(2 * (cont - 1) + 2) = cont + L - 1;

  end do

End Subroutine neighbors

Subroutine energia_ini
  
  Use Variaveis
  Implicit None
  
  Integer*4 i
  
  ener = 0.0d0
  
  Do i = 1, nsitios

    ener = ener - S(i) * S(viz(2 * (i - 1) + 1))

  end do

End Subroutine energia_ini

Subroutine monte_carlo

  Use Variaveis
  Implicit None

  Real*8 ran, dE;
  Integer*4 k;

  Do k = 1, nsitios

    dE = 2.0d0 * S(k) * (S(viz(2 * (k - 1) + 1)) + S(viz(2 * (k - 1) + 2)));

    if( dE < 0.0d0 )then

      S(k) = -1.0d0 * S(k);
      ener = ener + dE;

    else
      
      Call random_number(ran)
      
      if( dexp(-dE * beta) > ran )then
      
        S(k) = -1.0d0 * S(k);
        ener = ener + dE;

      end if
    
    end if

  end do

End Subroutine monte_carlo

Subroutine temperatura_steps

  Use Variaveis
  Implicit None
  
  Integer*4 i, k;
  Real*8 E2_mean, E_mean, M_mean
  
  temp = Temp_ini;
  
  Do k = 1, temp_steps
  
    write(*,'(1x,"Temperatura: ",F7.4)') temp;
    beta = 1.0d0 / temp;

! Passos de termalização ==!
  
    Do i = 1, term_steps
   
      Call monte_carlo;

    end do

! Passos de Monte Carlo ====!  

    E = 0.0d0

    Do i = 1, mc_steps
  
      Call monte_carlo;
    
      E(i) = ener
      M(i) = sum(S)

    end do

    E2_mean = sum(E**2) / dble(mc_steps)

    E_mean = sum(E) / dble(mc_steps)
    
    M_mean = sum(M) / dble(mc_steps)

    write(*,'(1x,"E: ",F8.4)') E_mean;
    write(*,'(1x,"M: ",F8.4)') M_mean / dble(nsitios);
    write(*,'(1x,"Cv: ",F8.4)') (E2_mean - E_mean**2) / dble(nsitios * temp**2)

    temp = temp - dt;

  end do
  
End Subroutine temperatura_steps

SUBROUTINE init_random_seed()
  INTEGER :: i, n, clock
  INTEGER, DIMENSION(:), ALLOCATABLE :: seed
          
  CALL RANDOM_SEED(size = n)
  ALLOCATE(seed(n))
          
  CALL SYSTEM_CLOCK(COUNT=clock)
          
  seed = clock + 37 * (/ (i - 1, i = 1, n) /)
  CALL RANDOM_SEED(PUT = seed)
          
  DEALLOCATE(seed)
END SUBROUTINE