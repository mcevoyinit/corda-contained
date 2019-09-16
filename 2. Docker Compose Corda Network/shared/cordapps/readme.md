CorDapps
========

 1. The business network operator functionality is provided by the [memberships-management](corda-solutions/bn-apps/memberships-management) CorDapp. This app is open source and available at https://github.com/corda/corda-solutions
 2. The [trusting-cordapp](trusting-cordapp) is a simple demo of the BNO functionality.
 
_1_ needs to be present on all participant nodes and on the business network operator node.
_2_ needs to be present on all participant nodes.

The notary does not require access to the CorDapp if run in non-validating mode.