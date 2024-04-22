---
title: "Compliance as Code"
author: "Clemens Schotte"
date: 2021-03-22

tags: ["Azure", "DevOps", "IaC", "Testing"]
categories: ["DevOps"]

resources:
- name: "featured-image"
  src: "featured-image.jpg"

draft: false
lightgallery: true
---

## Compliance-as-Code

### What is compliance as code?

Compliance-as-Code can be summarized as the organizational capability to **automate** the implementation, verification, remediation, monitoring, and compliance status reporting. This automation comes in the form of code and is integrated into the code repositories used by Devs and Engineers. It becomes "just another piece of code."

* Using code to describe, validate, (possibly) remediate, monitor, and report compliance requirements and status
* Measured against regulatory standards and internal governance
* Includes (but not limited to):
    * Security
    * Infrastructure configuration
    * Privacy
    * Policies: Government, finance, health, etc.
    * Licensing (i.e., Open Source)

### Why use compliance as code?

Just as with any other *aC, precision and repeatability of code execution eliminate human error.

* Precisions and repeatability 
* Reduced effort on repetition 
* Integrates compliance into daily practices, mitigating compliance knowledge silos
* Enables and simplifies audits through programmatically defined evidence gathering processes

### How to use compliance as code?

Code the requirements as a test. Use descriptive approaches as PowerShell Desired State Configuration (DSC) vs just code as they are simpler to understand, read and maintain. Run compliance tests whenever possible, not just at later stages. Run them while in production to detect unexpected changes (drifts) from the described initially.

* Implemented as tests (multiple levels)
* Promote descriptive approaches vs pure code
* Run compliance tests early and frequently (shift left)
* Run compliance tests late to detect breaches and drifts (shift right)
* Multiple tools available: PowerShell DSC, [InsPec](https://www.inspec.io/), [Open Policy Agent](https://www.openpolicyagent.org/)

## Infrastructure-as-Code

Infrastructure-as-Code (IaC) is a well-known approach by which the infrastructure requirements are described in code and configuration files. In turn, when executed, it generates the infrastructural artifacts necessary to support the solution.
 
With the advent of virtual infrastructure, IaC found its space and brought all the advantages of code (speed, repeatability, and human error removal). But as with any other artifacts of a solution, we need to validate and enforce quality.

IaC is only an effective tool when you incorporate this into your DevOps process, and you are willing to run tests and validate your code continuously. Otherwise, you run serious risks when it comes to application security and function. With IaC, your applications can be continually updated while running, and everything is still under compliance. This is a significant advantage, but it requires a certain degree of monitoring to react as unknown issues arise.

### Challenges

* The declarative approach is hard to test
* Long test cycles
* The complexity of modern architectures
* Highly distributed systems

### Different Validation Strategies

#### Static or style checks

* Visual inspection
* Validates format, naming conventions, structure
* Static code analysis, linting, etc.
* Can be executed during build pipelines

#### Unit tests

* Validate the correct functionality of each IaC file/directive
* Executed after the IaC has been deployed
* Executed in the release phase/pipeline

#### Integration and system tests

* Validates the complete flow of the multiple IaC artifacts
* Executed after passing unit tests
* Typically used in Integration/Quality/Pre-production/Production
* Excellent tool for blue/green deployment strategies

#### Monitoring

* Validates alignment with predefined
* Identifies drifts
* Excellent tool for monitoring platform stability and health

## Testing Tools

### Pester

[Pester](https://pester.dev/) is an testing- and mocking framework for PowerShell. Pester is most commonly used for writing unit and integration tests. It is also a base for tools that validate whole environments, cloud deployments, database configurations, etc.

Pester follows a file naming convention *.Tests.ps1, and uses a simple set of functions: `Describe`, `Context`, `It`, `Should`, and `Mock` to create a mini-DSL for writing tests.

Tests can be run locally and should be integrated into a build script in a CI pipeline. Pester can produce artifacts such as **Code Coverage** and **Test Result** files for reporting results in CI pipeline.

We test our implementation by validating within our tests that the requirements are present in our configuration file. If changes to the ARM template happen, we can still ensure our requirements are met if all tests are passed. The output of these tests is written in a human-readable way and can be interpreted by non-technical people.

In this example, we will query for the Storage Accounts. The object returned will have all configured properties. Otherwise, we can get the deployed resource by using:

`Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts’`

To ensure the specification is met, we need to add assertions based on the specification. These assertions should validate that the properties are set correctly on the deployed Azure Resource.

```powershell
# adls.acceptance.spec.ps1

$adls = Get-AzStorageAccount -Name $resource.Name -ResourceGroupName $resource.ResourceGroupName

Describe "$Name Data Lake Storage Account Generation 2" {
    # Mandatory requirement of ADLS Gen 2 are:
    # - Resource Type is Microsoft.Storage/storageAccounts, 
    #   as we know we are looking for this it is obsolete to check
    # - Kind is StorageV2
    # - Hierarchical namespace is enabled

    it "should be of kind StorageV2" {
        $adls.Kind | Should -Be "StorageV2"
    }

    it "should have Hierarchical Namespace Enabled" {
        $adls.EnableHierarchicalNamespace | Should -Be $true
    }

    ...
}
```

### Inspec

[Inspec](https://community.chef.io/tools/chef-inspec/) is a command line, an open-source tool provided by Chef with an audit and automated testing framework for integration, compliance, and security. It does not require learning a new language, just knowing how to write the desired state of infrastructure resources. With Inspec, you can test the compliance of remotes machines, data, and cloud infrastructures like Azure and others.

* **Test the desired state** Verify your applications and infrastructure's current desired state according to the code you write.
* **Human-readable code** Reduce friction by writing tests that are easy to understand by anyone.
* **Extensible** Create custom resources with ease and share them easily with others

```Ruby
describe file('/etc/myapp.conf') do
  it { should exist }
 
its('mode') { should cmp 0644 }
end

describe apache_conf do
 
its('Listen') { should cmp 8080 }
end

describe port(8080) do
  it { should be_listening }
end
```

### Azure Resource Manager Template Toolkit

The [Azure Resource Manager template (ARM template) test toolkit](https://github.com/Azure/arm-ttk) checks whether your template uses recommended practices. When your template isn't compliant with recommended practices, it returns a list of warnings with the suggested changes. By using the test toolkit, you can learn how to avoid common problems in template development.

The test toolkit provides a set of default tests. These tests are recommendations but not requirements. You can decide which tests are relevant to your goals and customize which tests are run.

The toolkit is a set of PowerShell scripts that can be run from a command in PowerShell or CLI.

## Additional reads

* [Test your Azure infrastructure compliance with Inspec](https://medium.com/@mikakrief/test-your-azure-infrastructure-compliance-with-inspec-9ac9f47ffb88)
* [5 Lessons Learned From Writing Over 300,000 Lines of Infrastructure Code](https://blog.gruntwork.io/5-lessons-learned-from-writing-over-300-000-lines-of-infrastructure-code-36ba7fadeac1)
* [Terratest: a swiss army knife for testing infrastructure code](https://blog.gruntwork.io/open-sourcing-terratest-a-swiss-army-knife-for-testing-infrastructure-code-5d883336fcd5)
* [Testing ARM Templates with Pester](https://devkimchi.com/2018/01/22/testing-arm-templates-with-pester/)