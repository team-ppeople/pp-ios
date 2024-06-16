//
//  TermsAgreementView.swift
//  pp
//
//  Created by 김지현 on 2024/04/05.
//

import SwiftUI

struct TermsAgreementView: View {
	@ObservedObject var vm: LoginViewModel
    @ObservedObject var communityVm: CommunityViewModel
	@State var privacyTermsToggleIsOn: Bool = false
	@State var serviceTermsToggleIsOn: Bool = false
	@State var allTermsToggleIsOn: Bool = false
	@State private var color: Color = .sub
	
	var body: some View {
		VStack {
			Toggle(isOn: $privacyTermsToggleIsOn, label: {
				HStack {
					Image(systemName: "checkmark.circle")
						.tint(privacyTermsToggleIsOn ? .accent : .sub)
					Text("개인정보 처리 방침")
						.tint(.black)
						.font(.system(size: 16))
					Text("(필수)")
						.frame(maxWidth: .infinity, alignment: .leading)
						.tint(.darkSub)
						.font(.system(size: 14))
					Button {} label: {
						Link(destination: URL(string: Url.privacyPolicy.rawValue)!) {
							Image(systemName: "chevron.right")
								.tint(.black)
						}
					}
				}
				.frame(maxWidth: .infinity)
				.padding(.vertical, 10)
				.padding(.horizontal, 12)
				.overlay(
					RoundedRectangle(cornerRadius: 5)
						.stroke(privacyTermsToggleIsOn ? .accent : .sub, lineWidth: 1)
				)
			})
			.toggleStyle(.button)
			.tint(.clear)
			.onChange(of: privacyTermsToggleIsOn) { isOn in
				if !allTermsToggleIsOn && serviceTermsToggleIsOn {
					allTermsToggleIsOn = true
				} else if !privacyTermsToggleIsOn || !serviceTermsToggleIsOn || !isOn {
					allTermsToggleIsOn = false
				}
			}
			.padding(.top, 10)
			
			Toggle(isOn: $serviceTermsToggleIsOn, label: {
				HStack {
					Image(systemName: "checkmark.circle")
						.tint(serviceTermsToggleIsOn ? .accent : .sub)
					Text("서비스 이용 약관")
						.tint(.black)
						.font(.system(size: 16))
					Text("(필수)")
						.frame(maxWidth: .infinity, alignment: .leading)
						.tint(.darkSub)
						.font(.system(size: 14))
					Button {} label: {
						Link(destination: URL(string: Url.termsAndCondition.rawValue)!) {
							Image(systemName: "chevron.right")
								.tint(.black)
						}
					}
				}
				.frame(maxWidth: .infinity)
				.padding(.vertical, 10)
				.padding(.horizontal, 12)
				.overlay(
					RoundedRectangle(cornerRadius: 5)
						.stroke(serviceTermsToggleIsOn ? .accent : .sub, lineWidth: 1)
				)
			})
			.toggleStyle(.button)
			.tint(.clear)
			.onChange(of: serviceTermsToggleIsOn) { isOn in
				if !allTermsToggleIsOn && privacyTermsToggleIsOn {
					allTermsToggleIsOn = true
				} else if !privacyTermsToggleIsOn || !serviceTermsToggleIsOn || !isOn {
					allTermsToggleIsOn = false
				}
			}
			
			Spacer()
			
			Toggle(isOn: $allTermsToggleIsOn, label: {
				HStack {
					Image(systemName: "checkmark.circle")
						.tint(allTermsToggleIsOn && privacyTermsToggleIsOn && serviceTermsToggleIsOn ? .accent : .sub)
					Text("모두 동의")
						.tint(.black)
					
					Spacer()
				}
			})
			.toggleStyle(.button)
			.tint(.clear)
			.onChange(of: allTermsToggleIsOn) { isOn in
				if isOn {
					privacyTermsToggleIsOn = true
					serviceTermsToggleIsOn = true
				} else if privacyTermsToggleIsOn && serviceTermsToggleIsOn {
					privacyTermsToggleIsOn = false
					serviceTermsToggleIsOn = false
				}
			}
			
			Button {
				vm.login()
			} label: {
				Text("필수 약관 동의 완료")
					.padding(.vertical, 12)
			}
			.frame(maxWidth: .infinity)
			.background(color)
			.clipShape(RoundedRectangle(cornerRadius: 5))
			.tint(.white)
			.onChange(of: allTermsToggleIsOn) { isOn in
				if isOn {
					color = .accentColor
				} else {
					color = .sub
				}
			}
			.padding(.horizontal, 16)
			.padding(.bottom, 20)
			.disabled(!allTermsToggleIsOn)
		}
		.navigationBarTitle("약관동의", displayMode: .inline)
		.navigationDestination(isPresented: $vm.isTermsLinkActive) {
			switch vm.destination {
			case .community:
                CommunityView(vm: communityVm)
			default:
                CommunityView(vm: communityVm)
			}
		}
	}
}

//#Preview {
//	TermsAgreementView(vm: LoginViewModel())
//}
