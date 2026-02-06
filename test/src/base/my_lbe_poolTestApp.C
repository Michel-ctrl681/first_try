//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "my_lbe_poolTestApp.h"
#include "my_lbe_poolApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
my_lbe_poolTestApp::validParams()
{
  InputParameters params = my_lbe_poolApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

my_lbe_poolTestApp::my_lbe_poolTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  my_lbe_poolTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

my_lbe_poolTestApp::~my_lbe_poolTestApp() {}

void
my_lbe_poolTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  my_lbe_poolApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"my_lbe_poolTestApp"});
    Registry::registerActionsTo(af, {"my_lbe_poolTestApp"});
  }
}

void
my_lbe_poolTestApp::registerApps()
{
  registerApp(my_lbe_poolApp);
  registerApp(my_lbe_poolTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
my_lbe_poolTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  my_lbe_poolTestApp::registerAll(f, af, s);
}
extern "C" void
my_lbe_poolTestApp__registerApps()
{
  my_lbe_poolTestApp::registerApps();
}
