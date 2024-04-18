//
//  TermsAgreementView.swift
//  pp
//
//  Created by 김지현 on 2024/04/05.
//

import SwiftUI

struct TermsAgreementView: View {
    @State var privacyTermsToggleIsOn: Bool = false
    @State var serviceTermsToggleIsOn: Bool = false
    @State var allTermsToggleIsOn: Bool = false
    @State private var navigateToCommunityView = false // 화면 전환을 위한 상태 변수
    
    var body: some View {
        VStack {
            Toggle(isOn: $privacyTermsToggleIsOn, label: {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .tint(privacyTermsToggleIsOn ? .accent : .sub)
                    Text("개인정보 처리 방침")
                        .tint(.black)
                    Text("(필수)")
                        .tint(.darkSub)
                    Button {} label: {
                        NavigationLink(destination: TermsView()) {
                            Image(systemName: "chevron.right")
                                .tint(.black)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .border(width: 1, edges: [.top, .bottom, .leading, .trailing], color: privacyTermsToggleIsOn ? .accent : .sub)
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
            
            Toggle(isOn: $serviceTermsToggleIsOn, label: {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .tint(serviceTermsToggleIsOn ? .accent : .sub)
                    Text("서비스 이용 약관")
                        .tint(.black)
                    Text("(필수)")
                        .tint(.darkSub)
                    Button {} label: {
                        NavigationLink(destination: TermsView()) {
                            Image(systemName: "chevron.right")
                                .tint(.black)
                        }
                    }
                }
                .border(width: 1, edges: [.top, .bottom, .leading, .trailing], color: serviceTermsToggleIsOn ? .accent : .sub)
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
            
            Toggle(isOn: $allTermsToggleIsOn, label: {
                HStack {
                    Image(systemName: "checkmark.circle")
                        .tint(allTermsToggleIsOn && privacyTermsToggleIsOn && serviceTermsToggleIsOn ? .accent : .sub)
                    Text("모두 동의")
                        .tint(.black)
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
           
            Button("필수 약관 동의 완료") {
                // 임시 화면전환
                navigateToCommunityView = true // 버튼 클릭 시 상태 변수 변경
                
            }
            .background(.accent)
            NavigationLink("", destination: CommunityView(), isActive: $navigateToCommunityView) // 활성화 상태에 따라 화면 전환
        }
        .navigationTitle("약관동의")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close") {
                    // 화면 닫기 코드
                }
                //.toolbar(.hidden, for: .tabBar)
            }
        }
    }
}
#Preview {
    TermsAgreementView()
}
