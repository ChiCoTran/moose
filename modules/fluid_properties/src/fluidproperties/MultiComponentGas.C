#include "MultiComponentGas.h"

registerMooseObject("FluidPropertiesApp", MultiComponentGas);

InputParameters
MultiComponentGas::validParams()
{
  InputParameters params = MultiComponentFluidProperties::validParams();
  params.addRequiredParam<UserObjectName>("fp0", "fluid component 0 name");
  params.addRequiredParam<UserObjectName>("fp1", "fluid component 1 name");
  params.addRequiredParam<Real>("Xmass0", "Mass fraction variables for component 0");
  return params;
}

// This is a constructor
MultiComponentGas::MultiComponentGas(const InputParameters & parameters)
  : MultiComponentFluidProperties(parameters)
{
  _fp_0 = &getUserObject<SinglePhaseFluidProperties>("fp0");
  _fp_1 = &getUserObject<SinglePhaseFluidProperties>("fp1");
  _xmass_0 = getParam<Real>("Xmass0");
}

// This is a destructor
MultiComponentGas::~MultiComponentGas() {}

void
MultiComponentGas::rho_mu_from_p_T(Real pressure, Real temperature, Real & _rho, Real & _mu) const
{
  _rho = _xmass_0 * _fp_0->rho_from_p_T(pressure, temperature) +
         (1 - _xmass_0) * _fp_1->rho_from_p_T(pressure, temperature);
  _mu = _xmass_0 * _fp_0->mu_from_p_T(pressure, temperature) +
        (1 - _xmass_0) * _fp_1->mu_from_p_T(pressure, temperature);
}
