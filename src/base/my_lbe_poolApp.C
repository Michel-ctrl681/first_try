#include "my_lbe_poolApp.h"
#include "MooseApp.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
my_lbe_poolApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

my_lbe_poolApp::my_lbe_poolApp(const InputParameters & parameters) : MooseApp(parameters)
{
  my_lbe_poolApp::registerAll(_factory, _action_factory, _syntax);
}

my_lbe_poolApp::~my_lbe_poolApp() {}

void
my_lbe_poolApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  Registry::registerObjectsTo(f, {"my_lbe_poolApp"});
  Registry::registerActionsTo(af, {"my_lbe_poolApp"});

  ModulesApp::registerAllObjects<my_lbe_poolApp>(f, af, s);
}

void
my_lbe_poolApp::registerApps()
{
  registerApp(my_lbe_poolApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
my_lbe_poolApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  my_lbe_poolApp::registerAll(f, af, s);
}
extern "C" void
my_lbe_poolApp__registerApps()
{
  my_lbe_poolApp::registerApps();
}
