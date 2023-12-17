//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#pragma once

#include "MultiComponentFluidProperties.h"

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Woverloaded-virtual"

/**
 *
 */
class MultiComponentGas : public MultiComponentFluidProperties
{
public:
  static InputParameters validParams();

  MultiComponentGas(const InputParameters & parameters);
  virtual ~MultiComponentGas();

  virtual void rho_mu_from_p_T(Real pressure, Real temperature, Real & rho, Real & mu) const;

protected:
  /// The name of the user object that provides fluid component 0 properties
  const SinglePhaseFluidProperties * _fp_0;
  /// The name of the user object that provides fluid component 1 properties
  const SinglePhaseFluidProperties * _fp_1;

  /// mass fraction of 0th component
  Real _xmass_0;

  /// mixed density
  Real _rho;
  /// Mixed viscosity
  Real _mu;
};

#pragma GCC diagnostic pop
